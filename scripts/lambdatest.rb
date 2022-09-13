require 'yaml'
require 'rspec'
require 'appium_lib'

TASK_ID = (ENV['TASK_ID'] || 0).to_i
CONFIG_NAME = ENV['CONFIG_NAME'] || 'single'

CONFIG = YAML.load(File.read(File.join(File.dirname(__FILE__), "../config/#{CONFIG_NAME}.config.yml")))
CONFIG['user'] = ENV['LT_USERNAME'] || CONFIG['user']
CONFIG['key'] = ENV['LT_ACCESS_KEY'] || CONFIG['key']




RSpec.configure do |config|
  config.around(:example) do |example|
    @caps = CONFIG['common_caps'].merge(CONFIG['browser_caps'][TASK_ID])
    @caps["name"] = ENV['name'] || example.metadata[:name] || example.metadata[:file_path].split('/').last.split('.').first

    puts @caps.inspect
    b= @caps["deviceName"].inspect
    v= @caps["isRealMobile"].inspect
    p= @caps["platform"].inspect
    c=@caps["platformVersion"].inspect
    app=@caps["app"].inspect


    deviceName= b.gsub("\"", "")
    platformVersion=c.gsub("\"", "")
    isRealMobile= v.gsub("\"", "")
    platform= p.gsub("\"", "")
    app=app.gsub("\"", "")
     

    caps={ 
  
      "LT:Options" => {

   
    "build" => "Ruby RSpec",
    "name" => "Sample Test",
    "platformName" => platform,
    "isRealMobile" => isRealMobile,
    "deviceName" => deviceName,
    "platformVersion" => platformVersion,
    "app" => app,
    "w3c" => true
    },
    
    }

    

    #@driver = Selenium::WebDriver.for(:remote,:url => "https://#{CONFIG['user']}:#{CONFIG['key']}@#{CONFIG['server']}/wd/hub",:capabilities => @caps)

    appium_driver = Appium::Driver.new({
      'caps' => caps,
      'appium_lib' => {
          :server_url => "https://#{CONFIG['user']}:#{CONFIG['key']}@#{CONFIG['server']}/wd/hub"
      }}, true)
    @driver = appium_driver.start_driver
    puts @driver.inspect
    session_id = @driver.session_id
    begin
      example.run
    ensure
      @driver.quit
    end
  end
end
