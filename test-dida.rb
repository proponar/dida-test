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

  def open_edit
    driver.find_element(xpath: '//button[@aria-label="Editovat heslo"]').click
    wait_for(class: 'MuiDialogTitle-root')
  end

  def test_all
    login
    search_entry('husa')
    open_edit
    sleep 5
  ensure
    driver.quit
  end
end

DidaTest.new.test_all
