# 使用官方 Python 镜像
FROM python:3.12-slim

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    wget \
    gnupg2 \
    unzip \
    ca-certificates \
    curl \
    jq \
    && rm -rf /var/lib/apt/lists/*

# 安装 Google Chrome
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/googlechrome-linux-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/googlechrome-linux-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# 获取 Chrome 版本并从 chrome-for-testing 下载匹配的 Chromedriver
RUN CHROME_VERSION=$(google-chrome --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -1) \
    && echo "Chrome 完整版本: $CHROME_VERSION" \
    && MAJOR_VERSION=$(echo "$CHROME_VERSION" | cut -d. -f1-3) \
    && echo "主版本: $MAJOR_VERSION" \
    && DRIVER_JSON=$(curl -s "https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json") \
    && DRIVER_URL=$(echo "$DRIVER_JSON" | jq -r '.version | .[] | select(.version == "'"$CHROME_VERSION"'") | .downloads.chromedriver[] | select(.platform == "linux64") | .url') \
    && if [ -z "$DRIVER_URL" ]; then \
         echo "未找到匹配的 Chromedriver，尝试用主版本: $MAJOR_VERSION"; \
         DRIVER_URL=$(echo "$DRIVER_JSON" | jq -r '.version | .[] | select(.version | startswith("'"$MAJOR_VERSION"'.")) | .downloads.chromedriver[] | select(.platform == "linux64") | .url' | head -1); \
       fi \
    && echo "Chromedriver 下载地址: $DRIVER_URL" \
    && wget -O /tmp/chromedriver.zip "$DRIVER_URL" \
    && unzip /tmp/chromedriver.zip -d /tmp \
    && find /tmp -name chromedriver -exec mv {} /usr/bin/chromedriver \; \
    && chmod +x /usr/bin/chromedriver \
    && rm -rf /tmp/chromedriver*

# 复制 Python 代码
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .

# 运行
CMD ["python", "main.py"]
