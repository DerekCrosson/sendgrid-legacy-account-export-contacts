# NOTE: THIS IS A QUICK SCRIPT I WROTE TO EXPORT SOME DATA TODAY. USE AT YOUR OWN RISK. THERE'S NOTHING REALLY DANGEROUS HERE, JUST SOME BADLY WRITTEN AND UNTESTED CODE
# TO RUN: open a terminal and type "irb" without quotes to get a Ruby REPL. Replace the environment variables. Copy and paste the code and press enter. Then check for the filename in the same directory.
# FOR NEW ACCOUNTS USE THE API EXPORT ENDPOINT

require 'sendgrid-ruby'
include SendGrid

def save_contacts_to_file(file, contact_list)
  contacts = JSON.parse(contact_list)["recipients"]
  file.puts "id,email,created_at,updated_at,last_emailed,last_clicked,last_opened,first_name,last_name"
  
  # TODO: clean up this messy code
  contacts.each do |contact|
    file.puts "#{contact["id"]},#{contact["email"]},#{contact["created_at"]},#{contact["updated_at"]},#{contact["last_emailed"]},#{contact["last_clicked"]},#{contact["last_opened"]},#{contact["first_name"]},#{contact["last_name"]}"
  end
end

# TODO: calculate number of pages from list size and create multiple requests
sendgrid = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
params = JSON.parse('{
  "list_id": ENV['SENDGRID_LIST_ID']
  "page": ENV['PAGE_NUMBER']
}')
list_id = ENV['SENDGRID_LIST_ID']

response = sendgrid.client.contactdb.lists._(list_id).recipients.get(query_params: params)
contact_list = response.body

# TODO: allow exporting of multiple lists at a time into multiple files
begin
  file = File.open(ENV['FILENAME_WITH_EXTENSION'],'w')
  save_contacts_to_file(file, contact_list)
rescue IOError => e
  puts "Error: #{e.message}"
ensure 
  file.close()
end
