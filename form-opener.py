from playwright.sync_api import sync_playwright
import time

adminPage = "https://colmis.robertomochetti.com/admin/"

with sync_playwright() as p:
    browser = p.firefox.launch(headless=True)  
    admin_page = browser.new_page()

    admin_page.goto(adminPage)
    admin_page.wait_for_selector(f"#openBtn")
    admin_page.click(f"#openBtn")
    print("Opened online form")
    
    time.sleep(75)

    browser.close()
    print("Form closed.")
