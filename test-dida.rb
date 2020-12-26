require 'selenium-webdriver'

class DidaTest
  def initialize
    @driver = Selenium::WebDriver.for :chrome
  end

  attr_reader :driver

  def wait_for(element={})
    # timeout in seconds
    Selenium::WebDriver::Wait.new(:timeout => 10).until { driver.find_element(element) }
  end

  def login
    driver.navigate.to "https://dida.hmpf.cz"
    wait_for(xpath: '//button[@type="submit"]')

    login, password = File.read('.pass').split(':')
    driver.find_element(xpath: '//input[@name="email"]').send_keys(login)
    driver.find_element(xpath: '//input[@name="password"]').send_keys(password)
    driver.find_element(xpath: '//button[@type="submit"]').click
    sleep(0.2)
    wait_for(:class => "MuiTableContainer-root")
  end
  
  def search_entry(text)
    driver.find_element(xpath: '//div[@name="hesloSel"]//input').send_keys(text)

    wait_for(class: 'MuiAutocomplete-popper')

    driver.find_element(xpath: '//div[@class="MuiAutocomplete-popper"]')
      .find_elements(tag_name: 'li')
      .each do |o|
      if text == o.text()
        o.click
        break
      end
    end
  end

  def open_edit_entry
    driver.find_element(xpath: '//button[@aria-label="Editovat heslo"]').click
    wait_for(class: 'MuiDialogTitle-root')
  end

  def close_entry
    driver.find_element(xpath: '//span[@class="MuiButton-label" and text()="Zrušit"]').click
  end

  def new_entry(heslo)
    driver.find_element(xpath: '//button[@aria-label="Přidat heslo"]').click
    wait_for(class: 'MuiDialogTitle-root')
    sleep(0.2)

    driver.find_element(xpath: '//input[@name="heslo"]').send_keys(heslo)
    driver.find_element(xpath: '//span[@class="MuiButton-label" and text()="Uložit"]').click
  end

  def new_exemp(text)
    driver.find_element(xpath: '//button[@aria-label="Přidat exemplifikaci"]').click
    wait_for(class: 'MuiDialogTitle-root')
    sleep(0.2)
    driver.find_element(xpath: '//textarea[@name="exemplifikace"]').send_keys(text)
    driver.find_element(xpath: '//input[@name="rok"]').send_keys('1984')
    driver.find_element(xpath: '//span[@class="MuiButton-label" and text()="Uložit"]').click

    # wait for row added at the main screen
    # FIXME: assuming that the new item is singular and fits on the screen
    wait_for(xpath: "//td[text()=\"#{text}\"]")
  end

  def edit_delete_exemp(text)
    driver.find_element(xpath: "//td[text()=\"#{text}\"]").click

    # wait for menu pop-up
    wait_for(xpath: '/html/body/div/div/ul/li')
    sleep(0.2)
    driver.find_element(xpath: '//ul/li[text()="Editovat"]').click

    wait_for(class: 'MuiDialogTitle-root')
    sleep(0.2)
    driver.find_element(xpath: '//span[@class="MuiButton-label" and text()="Smazat"]').click

    wait_for(xpath: '//h2[text()="Smazat exemplifikaci?"]')
    sleep(0.2)
    driver.find_element(xpath: '//span[@class="MuiButton-label" and text()="Ano"]').click
  end

  def test_all
    login
    search_entry('husa')
    open_edit_entry
    sleep(0.2)
    close_entry

    sleep(0.2)
    new_entry('test')
    sleep(0.2)
    #driver.find_element(xpath: '//button[@aria-label="Clear"]').click
    driver.find_element(xpath: '//div[@name="hesloSel"]//input').send_keys(:backspace, :backspace, :backspace, :backspace)
    search_entry('test')
    sleep(0.2)
    new_exemp('foobar')
    edit_delete_exemp('foobar')
    sleep 5
  ensure
    driver.quit
  end
end

DidaTest.new.test_all
