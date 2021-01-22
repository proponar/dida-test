require 'selenium-webdriver'
require 'test/unit'

class DidaTest < Test::Unit::TestCase
  def setup
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    @driver = Selenium::WebDriver.for(:chrome, options: options)
    @sleep_time = 0.2
  end

  attr_reader :driver

  def wait_for(element={})
    # timeout in seconds
    Selenium::WebDriver::Wait.new(:timeout => 10).until { driver.find_element(element) }
  end

  def login
    driver.navigate.to "https://dida.hmpf.cz"
    wait_for(xpath: '//button[@type="submit"]')

    login, password = File.read('.pass').chomp.split(':')
    driver.find_element(xpath: '//input[@name="email"]').send_keys(login)
    driver.find_element(xpath: '//input[@name="password"]').send_keys(password)
    sleep(@sleep_time)
    driver.find_element(xpath: '//button[@type="submit"]').click
    sleep(@sleep_time)
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
    sleep(@sleep_time)

    driver.find_element(xpath: '//input[@name="heslo"]').send_keys(heslo)
    driver.find_element(xpath: '//span[@class="MuiButton-label" and text()="Uložit"]').click
  end

  def new_exemp(text)
    driver.find_element(xpath: '//button[@aria-label="Přidat exemplifikaci"]').click
    wait_for(class: 'MuiDialogTitle-root')
    sleep(@sleep_time)
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
    sleep(@sleep_time)
    driver.find_element(xpath: '//ul/li[text()="Editovat"]').click

    wait_for(class: 'MuiDialogTitle-root')
    sleep(@sleep_time)
    driver.find_element(xpath: '//span[@class="MuiButton-label" and text()="Smazat"]').click

    wait_for(xpath: '//h2[text()="Smazat exemplifikaci?"]')
    sleep(@sleep_time)
    driver.find_element(xpath: '//span[@class="MuiButton-label" and text()="Ano"]').click
  end

  def teardown
    driver.quit
  end

  def test_all
    assert_nothing_thrown('login failed') do
      login
    end

    assert_nothing_thrown('edit entry failed') do
      search_entry('husa')
      open_edit_entry
      sleep(@sleep_time)
      close_entry
      sleep(@sleep_time)
    end

    assert_nothing_thrown('new entry failed') do
      new_entry('test')
      sleep(@sleep_time)
      #driver.find_element(xpath: '//button[@aria-label="Clear"]').click
      driver.find_element(xpath: '//div[@name="hesloSel"]//input').send_keys(:backspace, :backspace, :backspace, :backspace)
      search_entry('test')
      sleep(@sleep_time)
    end

    assert_nothing_thrown('create/remove exemp failed') do
      new_exemp('foobar')
      sleep(@sleep_time)
      edit_delete_exemp('foobar')
      sleep(@sleep_time)
    end
  end
end
