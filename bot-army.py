from playwright.sync_api import sync_playwright
import time

indexPage = "https://colmis.robertomochetti.com/"
adminPage = "https://colmis.robertomochetti.com/admin/"

with sync_playwright() as p:
    browser = p.firefox.launch(headless=True)  
    admin_page = browser.new_page()

    def control_form(status):
        admin_page.goto(adminPage)
        admin_page.wait_for_selector(f"#{status}Btn")
        admin_page.click(f"#{status}Btn")
        print("Clicked:", status)
        print("Status now:", admin_page.inner_text("#statusText"))

    def fill_form():
        print("Filling form.")
        form_pages = []
        for i in range(85):
            bot_id = i + 1
            form_text = f"Hello from bot{bot_id}! Hello from bot{bot_id}! Hello from bot{bot_id}!"

            form_page = browser.new_page()
            form_page.goto(indexPage)
            form_pages.append((form_page, form_text))

        for form_page, text in form_pages:
            try:
                form_page.wait_for_selector("#movementInput", timeout=5000)
                form_page.fill("#movementInput", form_text)
            except Exception as e:
                print(f"[ERROR] Could not fill page: {e}")
        print("Forms filled")

    # Run sequence
    control_form("reset")   
    time.sleep(10)
    control_form("open")   
    fill_form()

    # Optionally keep browser open for inspection
    print("All done. Browser will remain open.")
    input("Press Enter to close browser...")
    browser.close()
