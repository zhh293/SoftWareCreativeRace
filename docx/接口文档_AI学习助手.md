# AI 学习助手接口文档

版本：v1.0  
最后更新时间：2026-01-17  
后端技术栈：Python + FastAPI + PostgreSQL  
前端技术栈：Flutter（移动端与桌面端统一）

---

## 一、总体说明

AI 学习助手是一个面向学生与自学者的多模型学习助手。用户可以在应用中与不同大模型对话、使用精心设计的提示词模板进行学习辅导，并将对话自动整理为结构化的知识大纲和思维导图。


- API 基础地址（示例）：`https://api.ai-study-helper.com/api/v1`
- 所有接口返回统一的 JSON 格式
- 登录后的接口统一使用 JWT（Json Web Token）鉴权

---

## 二、统一约定

### 2.1 请求与返回的基本格式

- 请求协议：HTTPS
- 请求体格式：JSON
- 字符编码：UTF-8

通用返回结构：

```json
{
  "code": 0,
  "message": "OK",
  "data": { }
}
```

- `code`：业务状态码，`0` 表示成功，非 0 表示失败
- `message`：对当前结果的文字说明，便于前端直接展示给用户
- `data`：真正的业务数据内容

### 2.2 通用错误码约定

| code | 含义                 | 说明                                   |
|------|----------------------|----------------------------------------|
| 0    | 成功                 | 请求正常完成                           |
| 4001 | 参数校验失败         | 请求字段缺失或类型错误                 |
| 4003 | 未授权               | 未登录或 Token 无效                    |
| 4004 | 资源不存在           | 例如找不到指定的会话、思维导图等       |
| 4005 | 权限不足             | 当前用户没有操作该资源的权限           |
| 5000 | 服务器内部错误       | 未预期异常                             |
| 5001 | 第三方模型服务异常   | 大模型服务不可用或返回错误             |

### 2.3 鉴权方式（JWT）

登录成功后，后端会返回一个 `access_token`。  
前端在调用需要登录的接口时，需要在请求头中携带：

```http
Authorization: Bearer {access_token}
```

例如：

```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

## 三、用户与认证模块

### 3.1 用户注册

- 描述：创建新用户账号
- 方法与路径：`POST /auth/register`
- 是否需要登录：否

**请求头**

| 名称         | 必填 | 说明             |
|--------------|------|------------------|
| Content-Type | 是   | `application/json` |

**请求体**

```json
{
  "email": "student@example.com",
  "password": "12345678",
  "nickname": "小明",
  "invitation_code": "ABC123"
}
```

字段说明：

| 字段名          | 类型   | 必填 | 说明                                   |
|-----------------|--------|------|----------------------------------------|
| email           | string | 是   | 用户邮箱，作为登录账号                 |
| password        | string | 是   | 登录密码，前端需做基本长度校验         |
| nickname        | string | 否   | 昵称，用于展示                         |
| invitation_code | string | 否   | 邀请码，可选，用于活动或统计           |

**响应示例（成功）**

```json
{
  "code": 0,
  "message": "注册成功",
  "data": {
    "user_id": "u_123456",
    "email": "student@example.com",
    "nickname": "小明",
    "created_at": "2026-01-17T10:00:00Z"
  }
}
```

**常见错误**

- `4001`：邮箱格式不正确、密码长度太短等
- `4005`：邮箱已被注册

---

### 3.2 用户登录

- 描述：使用邮箱和密码登录，获取访问令牌
- 方法与路径：`POST /auth/login`
- 是否需要登录：否

**请求体**

```json
{
  "email": "student@example.com",
  "password": "12345678"
}
```

**响应示例（成功）**

```json
{
  "code": 0,
  "message": "登录成功",
  "data": {
    "access_token": "jwt-token-string",
    "token_type": "bearer",
    "expires_in": 7200,
    "user": {
      "user_id": "u_123456",
      "email": "student@example.com",
      "nickname": "小明",
      "avatar_url": null
    }
  }
}
```

字段说明：

| 字段名       | 类型   | 说明                          |
|--------------|--------|-------------------------------|
| access_token | string | 后续访问需要登录的接口时使用 |
| token_type   | string | 固定为 `bearer`              |
| expires_in   | int    | Token 过期时间（秒）          |
| user         | object | 当前用户的基本信息           |

**常见错误**

- `4003`：邮箱或密码错误

---

### 3.3 获取当前用户信息

- 描述：获取当前登录用户的详细信息
- 方法与路径：`GET /auth/me`
- 是否需要登录：是

**请求头**

- `Authorization: Bearer {access_token}`

**响应示例**

```json
{
  "code": 0,
  "message": "OK",
  "data": {
    "user_id": "u_123456",
    "email": "student@example.com",
    "nickname": "小明",
    "avatar_url": null,
    "created_at": "2026-01-17T10:00:00Z",
    "preferences": {
      "theme": "light",
      "language": "zh-CN"
    }
  }
}
```

---

### 3.4 更新用户资料

- 描述：修改昵称、头像、偏好设置等
- 方法与路径：`PUT /auth/me`
- 是否需要登录：是

**请求体（部分字段可选）**

```json
{
  "nickname": "小明同学",
  "avatar_url": "https://example.com/avatar.png",
  "preferences": {
    "theme": "light",
    "language": "zh-CN"
  }
}
```

---

## 四、模型与提示词配置模块

该模块的目标是：**支持多个大模型，并对每个模型配置合适的提示词模板**，让 AI 的回答更通俗、更适合学习。

### 4.1 查询可用模型列表

- 描述：获取系统当前支持的大模型列表以及每个模型的特点
- 方法与路径：`GET /models`
- 是否需要登录：是（也可根据需求调整）

**响应示例**

```json
{
  "code": 0,
  "message": "OK",
  "data": [
    {
      "model_id": "gpt4o",
      "name": "通用理解模型",
      "provider": "openai-compatible",
      "description": "擅长综合性解释、写作与代码示例",
      "recommended_scenes": ["概念讲解", "作业辅导"],
      "max_tokens": 8000
    },
    {
      "model_id": "deepthinker",
      "name": "深度推理模型",
      "provider": "third-party",
      "description": "偏向逻辑推理和解题步骤讲解",
      "recommended_scenes": ["数学解题", "逻辑推理题"],
      "max_tokens": 16000
    }
  ]
}
```

---

### 4.2 创建/编辑模型配置（后台管理用）

比赛中可以先只实现前端使用 `GET /models`，后台配置直接写在数据库或配置文件中。  
如果需要后台界面，可以预留：

- `POST /models`：创建模型配置
- `PUT /models/{model_id}`：更新模型配置

---

### 4.3 获取提示词预设列表

- 描述：获取系统内置的学习场景与提示词模板（例如「用生活中的比喻讲解」「按高考解题步骤来讲」）
- 方法与路径：`GET /prompt-presets`
- 是否需要登录：是

**响应示例**

```json
{
  "code": 0,
  "message": "OK",
  "data": [
    {
      "preset_id": "explain_like_friend",
      "name": "像同桌好朋友一样讲题",
      "description": "用轻松自然的语气来解释知识点，步骤清晰，有小例子。",
      "system_prompt": "你是一位耐心的同桌好友...",
      "default_model_id": "gpt4o"
    },
    {
      "preset_id": "exam_step_by_step",
      "name": "考试解题步骤拆解",
      "description": "适合刷题，按“读题-分析-列式-计算-检查”的结构回答。",
      "system_prompt": "你是一位认真负责的学科老师...",
      "default_model_id": "deepthinker"
    }
  ]
}
```

前端可以使用这些信息，在用户选择学习场景时展示卡片。

---

## 五、对话与会话管理模块

### 5.1 创建新会话

- 描述：用户在前端点击「新建学习对话」时调用，用于创建一个会话记录
- 方法与路径：`POST /conversations`
- 是否需要登录：是

**请求体**

```json
{
  "title": "高一物理力学复习",
  "model_id": "gpt4o",
  "preset_id": "explain_like_friend"
}
```

字段说明：

| 字段名   | 类型   | 必填 | 说明                         |
|----------|--------|------|------------------------------|
| title    | string | 否   | 会话标题，用户可留空         |
| model_id | string | 否   | 选中的模型 ID，不填用默认    |
| preset_id| string | 否   | 使用的提示词预设 ID，可选    |

**响应示例**

```json
{
  "code": 0,
  "message": "OK",
  "data": {
    "conversation_id": "c_10001",
    "title": "高一物理力学复习",
    "model_id": "gpt4o",
    "preset_id": "explain_like_friend",
    "created_at": "2026-01-17T10:30:00Z"
  }
}
```

---

### 5.2 发送消息并获取 AI 回复

- 描述：用户在会话中输入问题，后端转发到对应的大模型，并返回 AI 的回答
- 方法与路径：`POST /conversations/{conversation_id}/messages`
- 是否需要登录：是

**请求体**

```json
{
  "role": "user",
  "content": "帮我用简单的比喻讲一下牛顿第二定律。",
  "stream": false
}
```

字段说明：

| 字段名   | 类型    | 必填 | 说明                                         |
|----------|---------|------|----------------------------------------------|
| role     | string  | 是   | 固定为 `user`，表示用户发送的消息           |
| content  | string  | 是   | 用户输入的内容                              |
| stream   | boolean | 否   | 是否采用流式输出（前期可以先不实现）        |

**响应示例（非流式）**

```json
{
  "code": 0,
  "message": "OK",
  "data": {
    "message_id": "m_20001",
    "conversation_id": "c_10001",
    "role": "assistant",
    "content": "可以把牛顿第二定律想象成推购物车...",
    "tokens_used": 456,
    "created_at": "2026-01-17T10:31:00Z"
  }
}
```

**说明**

- 后端会将本次问答记录到数据库，用于后续生成思维导图和学习报告。

---

### 5.3 获取会话列表

- 描述：获取当前用户的历史会话，用于在前端展示会话列表
- 方法与路径：`GET /conversations`
- 是否需要登录：是

支持分页：

- Query 参数：`page`（默认 1）、`page_size`（默认 20）

**响应示例**

```json
{
  "code": 0,
  "message": "OK",
  "data": {
    "items": [
      {
        "conversation_id": "c_10001",
        "title": "高一物理力学复习",
        "model_id": "gpt4o",
        "last_message_summary": "讲解了牛顿第二定律的生活类比...",
        "updated_at": "2026-01-17T10:31:00Z"
      }
    ],
    "page": 1,
    "page_size": 20,
    "total": 1
  }
}
```

---

### 5.4 获取单个会话详情及消息列表

- 描述：进入某个会话时，用于加载历史消息
- 方法与路径：`GET /conversations/{conversation_id}/messages`
- 是否需要登录：是

**响应示例**

```json
{
  "code": 0,
  "message": "OK",
  "data": {
    "conversation": {
      "conversation_id": "c_10001",
      "title": "高一物理力学复习",
      "model_id": "gpt4o",
      "preset_id": "explain_like_friend"
    },
    "messages": [
      {
        "message_id": "m_20000",
        "role": "user",
        "content": "帮我用简单的比喻讲一下牛顿第二定律。",
        "created_at": "2026-01-17T10:30:30Z"
      },
      {
        "message_id": "m_20001",
        "role": "assistant",
        "content": "可以把牛顿第二定律想象成推购物车...",
        "created_at": "2026-01-17T10:31:00Z"
      }
    ]
  }
}
```

---

## 六、思维导图与知识结构化模块

### 6.1 从会话生成思维导图

- 描述：将一个会话中的对话内容自动整理为思维导图结构（节点与层级关系）
- 方法与路径：`POST /mindmaps`
- 是否需要登录：是

**请求体**

```json
{
  "conversation_id": "c_10001",
  "title": "牛顿力学知识脑图"
}
```

字段说明：

| 字段名          | 类型   | 必填 | 说明                       |
|-----------------|--------|------|----------------------------|
| conversation_id | string | 是   | 要生成思维导图的会话 ID    |
| title           | string | 否   | 思维导图标题，不填自动生成 |

**响应示例**

```json
{
  "code": 0,
  "message": "生成成功",
  "data": {
    "mindmap_id": "mm_30001",
    "title": "牛顿力学知识脑图",
    "root_node": {
      "id": "node_root",
      "text": "牛顿力学",
      "children": [
        {
          "id": "node_f2",
          "text": "牛顿第二定律",
          "children": [
            {
              "id": "node_f2_concept",
              "text": "F=ma 概念",
              "children": []
            }
          ]
        }
      ]
    },
    "created_at": "2026-01-17T10:40:00Z"
  }
}
```

前端可以根据 `root_node` 的树形结构生成思维导图视图（Flutter 端可以使用第三方思维导图库或自定义绘制）。

---

### 6.2 获取某个思维导图详情

- 描述：根据 ID 获取思维导图结构
- 方法与路径：`GET /mindmaps/{mindmap_id}`
- 是否需要登录：是

**响应示例**

与上面生成接口中的 `data` 结构一致。

---

### 6.3 列出某会话下的所有思维导图

- 描述：一个会话可能多次生成思维导图（不同版本），可通过该接口获取列表
- 方法与路径：`GET /mindmaps`
- 是否需要登录：是

Query 参数：

- `conversation_id`（必填）：会话 ID

---

## 七、学习笔记与收藏模块（可选但推荐）

### 7.1 创建学习笔记

- 描述：用户可以把某一段 AI 的回答整理为自己的学习笔记，加上自己的理解
- 方法与路径：`POST /notes`
- 是否需要登录：是

**请求体**

```json
{
  "conversation_id": "c_10001",
  "message_id": "m_20001",
  "title": "牛顿第二定律的生活类比",
  "content": "这里写我自己的理解...",
  "tags": ["物理", "力学", "高一"]
}
```

---

### 7.2 获取用户的笔记列表

- 方法与路径：`GET /notes`
- 是否需要登录：是

支持 `page`、`page_size` 分页，支持 `keyword` 搜索。

---

## 八、系统与运维相关接口（简单说明）

这些接口在比赛中可以不做前端页面，只要后端预留即可。

- `GET /health`：健康检查接口，返回服务是否正常。
- `GET /version`：返回当前后端版本号、构建时间等。

---

## 九、接口调用流程示例（给新手看的整体流程）

以下是一个典型的使用流程，帮助新手理解接口之间的关系：

1. 用户首次使用 App：  
   前端调用 `POST /auth/register` 创建账号。
2. 用户登录：  
   前端调用 `POST /auth/login`，拿到 `access_token`。
3. 前端保存 Token：  
   将 `access_token` 保存在本地（例如 SharedPreferences），并在后续所有需要登录的接口请求头中带上 `Authorization`。
4. 用户点击「新建学习对话」：  
   前端调用 `GET /models` 获取可用模型列表、`GET /prompt-presets` 获取学习场景。  
   用户选择模型和场景后，前端调用 `POST /conversations` 创建一个会话。
5. 用户向 AI 提问：  
   前端调用 `POST /conversations/{conversation_id}/messages`，发送用户的问题，拿到 AI 的回答。
6. 生成思维导图：  
   学习一段时间后，用户点击「生成脑图」按钮，前端调用 `POST /mindmaps`，后端从会话的历史消息中提取知识结构，返回树形数据，前端绘制思维导图。
7. 保存笔记：  
   用户觉得某个回答很重要，点击「保存为笔记」，前端调用 `POST /notes` 创建笔记。  
   后续可以通过 `GET /notes` 列出所有笔记。


