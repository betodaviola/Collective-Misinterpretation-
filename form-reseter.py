from playwright.sync_api import sync_playwright
import time

adminPage = "https://colmis.robertomochetti.com/admin/"

with sync_playwright() as p:
    browser = p.firefox.launch(headless=True)  
    admin_page = browser.new_page()

    admin_page.goto(adminPage)
    admin_page.wait_for_selector(f"#resetBtn")
    admin_page.click(f"#resetBtn")
    print("The online form has been reset. Online data has automatic backup that can be retrived.")
    
    browser.close()
