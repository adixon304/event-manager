require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcode(zipcode)
    zipcode.to_s.rjust(5, '0')[0..4]
end

def legislators_by_zipcode(zipcode)

    civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
    civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

    begin 
        civic_info.representative_info_by_address(
            address: zipcode,
            levels: 'country',
            roles: ['legislatorUpperBody', 'legislatorLowerBody']
        ).officials
    rescue
        'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
    end

end

def save_thank_you_letter(id, form_letter)

    Dir.mkdir('output') unless Dir.exist?('output')
    filename = "output/thanks_#{id}.html"

    File.open(filename, 'w') do |file|
        file.puts form_letter
    end
end


puts 'Event Manager initialized.'

contents = CSV.open(
    'event_attendees.csv',
     headers: true,
     header_converters: :symbol
    )

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents.each do |row|

    #get values from CSV file
    id = row[0]
    name = row[:first_name]
    zipcode = clean_zipcode(row[:zipcode]) #clean zip code if necessary

    #gather legislators from file's zipcode
    legislators = legislators_by_zipcode(zipcode)

    #build ERB template and form letter to send to customer
    form_letter = erb_template.result(binding)

    #save letter into an output folder
    save_thank_you_letter(id, form_letter)

end