# Docker Nginx with Brotli

一个支持 Brotli 压缩的 Nginx Docker 镜像项目，基于官方 Nginx 镜像构建，支持 Debian 和 Alpine 两种基础镜像。

## 特性

- 🚀 基于官方 Nginx 镜像构建
- 📦 支持 Debian 和 Alpine 两种基础镜像
- 🗜️ 内置 Google Brotli 压缩模块
- 🔄 自动跟踪 Nginx 官方版本更新
- 🎯 支持 stable 和 mainline 两个分支
- ⚡ 多架构支持

## 快速开始

### 使用预构建镜像

```bash
# 使用最新的 mainline 版本 (Debian)
docker run -d -p 80:80 ghcr.io/zvonimirsun/nginx-brotli:latest

# 使用 stable 版本 (Debian)
docker run -d -p 80:80 ghcr.io/zvonimirsun/nginx-brotli:stable

# 使用 Alpine 版本
docker run -d -p 80:80 ghcr.io/zvonimirsun/nginx-brotli:alpine

# 使用特定版本
docker run -d -p 80:80 ghcr.io/zvonimirsun/nginx-brotli:1.25.3
```

### Docker Compose 示例

```yaml
version: '3.8'

services:
  nginx:
    image: ghcr.io/zvonimirsun/nginx-brotli:latest
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./html:/usr/share/nginx/html:ro
    restart: unless-stopped
```

## 镜像标签说明

### Debian 基础镜像
- `latest` - 最新的 mainline 版本
- `stable` - 最新的 stable 版本
- `1.25.3` - 特定版本号
- `1.25` - 主要版本号

### Alpine 基础镜像
- `alpine` - 最新的 mainline Alpine 版本
- `stable-alpine` - 最新的 stable Alpine 版本
- `1.25.3-alpine` - 特定版本号的 Alpine 版本
- `1.25-alpine` - 主要版本号的 Alpine 版本

## Brotli 配置

Brotli 模块已经预装，需要手动引入加载，您可以在 Nginx 配置中启用它：

```nginx
load_module /usr/lib/nginx/modules/ngx_http_brotli_filter_module.so;
load_module /usr/lib/nginx/modules/ngx_http_brotli_static_module.so;

http {
    # 启用 Brotli 压缩
    brotli on;
    brotli_comp_level 6;
    brotli_types
        text/xml
        image/svg+xml
        application/x-javascript
        text/x-component
        text/css
        application/xml
        text/javascript
        application/javascript
        application/x-font-ttf
        application/vnd.ms-fontobject
        application/x-web-app-manifest+json
        font/opentype
        image/x-icon;
}
```

## 构建说明

本项目使用 GitHub Actions 自动构建多个版本的镜像：

### 支持的构建矩阵

| 平台 | 分支 | 描述 |
|------|------|------|
| debian | stable | Debian 基础的稳定版 |
| debian | mainline | Debian 基础的主线版 |
| alpine | stable | Alpine 基础的稳定版 |
| alpine | mainline | Alpine 基础的主线版 |

### 手动构建

```bash
# 克隆仓库
git clone https://github.com/zvonimirsun/docker-nginx-brotli.git
cd docker-nginx-brotli

# 构建 Debian 版本
docker build --build-arg NGINX_IMAGE=nginx:1.25.3 \
             --build-arg NGINX_VERSION=1.25.3 \
             --build-arg INSTALL_PKGS="apt-get update && apt-get install -y --no-install-recommends build-essential git libpcre3-dev libssl-dev zlib1g-dev libbrotli-dev wget" \
             -t nginx-brotli:1.25.3 .

# 构建 Alpine 版本
docker build --build-arg NGINX_IMAGE=nginx:1.25.3-alpine \
             --build-arg NGINX_VERSION=1.25.3 \
             --build-arg INSTALL_PKGS="apk add --update --no-cache build-base git pcre-dev openssl-dev zlib-dev linux-headers brotli-dev" \
             -t nginx-brotli:1.25.3-alpine .
```

## 工作流程

项目使用 GitHub Actions 自动化构建和发布：

1. **版本检测**: 自动从官方 Nginx 镜像获取最新版本号
2. **多平台构建**: 同时构建 Debian 和 Alpine 版本
3. **自动标签**: 根据版本和平台自动生成合适的镜像标签
4. **自动发布**: 构建完成后自动推送到 GitHub Container Registry

### 手动触发构建

您可以在 GitHub Actions 页面手动触发构建：

1. 进入 Actions 页面
2. 选择 "Publish Docker image" 工作流
3. 点击 "Run workflow"
4. 可选择指定特定的 Nginx 版本，或留空自动检测最新版本

## 文件结构

```
.
├── Dockerfile              # 多阶段构建文件
├── .github/
│   └── workflows/
│       └── publish.yml     # GitHub Actions 工作流
├── .gitignore
└── README.md
```

## 技术细节

### Dockerfile 特性
- 多阶段构建，减小最终镜像大小
- 动态编译 Brotli 模块，确保与 Nginx 版本兼容
- 自动配置时区为 Asia/Shanghai
- 预加载 Brotli 模块到 Nginx 配置

### 依赖说明
- **ngx_brotli**: Google 开发的 Nginx Brotli 模块
- **构建工具**: 根据基础镜像选择合适的编译工具链

## 许可证

本项目使用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

## 贡献

欢迎提交 Issue 和 Pull Request！

## 相关链接

- [Nginx 官方网站](https://nginx.org/)
- [ngx_brotli 模块](https://github.com/google/ngx_brotli)
- [Brotli 压缩算法](https://github.com/google/brotli)
