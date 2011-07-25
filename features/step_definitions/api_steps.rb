Given /^I have an api key for "([^\"]*)"$/ do |creds|
  user, pass = creds.split('/')
  page.driver.browser.basic_authorize(user, pass)
  visit api_v1_api_key_path
  @api_key = page.source
end

When /^I push the gem "([^\"]*)" with my api key$/ do |name|
  api_key_header
  path = File.join(TEST_DIR, name)
  page.driver.post api_v1_rubygems_path, File.read(path)
end

When /^I push an invalid .gem file$/ do
  api_key_header
  page.driver.post api_v1_rubygems_path, 'ZZZZZZZZZZZZZZZZZZ'
end

When /^I yank the gem "([^\"]*)" version "([^\"]*)" with my api key$/ do |name, version_number|
  api_key_header
  page.driver.delete yank_api_v1_rubygems_path(:gem_name => name, :version => version_number)
  assert_match /Successfully yanked gem: #{name} \(#{version_number}\)/, response.body
end

When /^I attempt to yank the gem "([^\"]*)" version "([^\"]*)" with my api key$/ do |name, version_number|
  api_key_header
  page.driver.delete yank_api_v1_rubygems_path(:gem_name => name, :version => version_number)
end

When /^I unyank the gem "([^\"]*)" version "([^\"]*)" with my api key$/ do |name, version_number|
  api_key_header
  page.driver.put unyank_api_v1_rubygems_path(:gem_name => name, :version => version_number)
  assert_match /Successfully unyanked gem: #{name} \(#{version_number}\)/, response.body
end

When /^I list the owners of gem "([^\"]*)" with my api key$/ do |name|
  api_key_header
  visit api_v1_rubygem_owners_path(:rubygem_id => name)
end

When /^I list the owners of gem "([^\"]*)" as "([^"]+)" with my api key$/ do |name, format|
  api_key_header
  visit "#{api_v1_rubygem_owners_path(name)}.#{format}"
end

When /^I add the owner "([^\"]*)" to the rubygem "([^\"]*)" with my api key$/ do |owner_email, rubygem_name|
  api_key_header
  page.driver.post api_v1_rubygem_owners_path(:rubygem_id => rubygem_name), :email => owner_email
end

When /^I remove the owner "([^\"]*)" from the rubygem "([^\"]*)" with my api key$/ do |owner_email, rubygem_name|
  api_key_header
  page.driver.delete api_v1_rubygem_owners_path(:rubygem_id => rubygem_name), :email => owner_email
end

When /^I download the rubygem "([^\"]*)" version "([^\"]*)" (\d+) times?$/ do |rubygem_name, version_number, count|
  count.to_i.times do
    visit "/gems/#{rubygem_name}-#{version_number}.gem"
  end
end

When 'I request "$url"' do |url|
  visit url
end

When /I list the gems with my api key/ do
  api_key_header
  visit api_v1_rubygems_path
end

Then /the response should contain "([^"]+)"/ do |text|
  assert_match text, page.source
end
