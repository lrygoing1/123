import os
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time

# 禁用 Selenium Manager
os.environ['SELENIUM_MANAGER_DISABLE'] = 'true'

# Chrome 配置
chrome_options = Options()
chrome_options.add_argument("--headless=new")
chrome_options.add_argument("--no-sandbox")
chrome_options.add_argument("--disable-dev-shm-usage")
chrome_options.add_argument("--disable-gpu")
chrome_options.add_argument("--disable-extensions")
chrome_options.add_argument("--window-size=1920,1080")
chrome_options.add_argument("--disable-search-engine-choice-screen")

# 手动指定 chromedriver
service = Service("/usr/bin/chromedriver")

print("正在启动 Chrome...")
driver = webdriver.Chrome(service=service, options=chrome_options)
print("Chrome 启动成功！")

def run():
    driver.get("https://gcli.ggchan.dev/")
    wait = WebDriverWait(driver, 20)

    print("输入账号...")
    wait.until(EC.presence_of_element_located((By.ID, "loginUsername"))).send_keys("lry")
    wait.until(EC.presence_of_element_located((By.ID, "loginPassword"))).send_keys("lrylry")
    wait.until(EC.element_to_be_clickable((By.CSS_SELECTOR, "button.btn.login-btn"))).click()

    print("等待登录...")
    wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, "button.btn[style*='flex: 1 1 0%']")))
    print("登录成功！开始监控...")

    while True:
        try:
            # 点击刷新数据
            refresh = driver.find_element(By.XPATH, "//button[contains(., '刷新数据')]")
            refresh.click()
            print("已刷新数据")
            time.sleep(2)

            # 检查启用按钮
            try:
                enable = driver.find_element(By.XPATH, "//button[contains(@class, 'btn-success') and contains(., '启用')]")
                enable.click()
                print("已点击 [启用]")
            except:
                pass

        except Exception as e:
            print(f"错误: {e}")

        time.sleep(3)

if __name__ == "__main__":
    try:
        run()
    except Exception as e:
        print(f"崩溃: {e}")
    finally:
        driver.quit()
