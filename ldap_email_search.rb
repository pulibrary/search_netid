#!/usr/bin/ruby

require 'net/ldap'

require 'pry'

def find_by_email(email, ldap_connection: default_connection)
  filter = Net::LDAP::Filter.eq('mail', email) # & Net::LDAP::Filter.eq('givenname', first_name) & Net::LDAP::Filter.eq('edupersonprimaryaffiliation','staff')
  result = ldap_connection.search(filter: filter)
  if result.empty?
    print "#{email},N/A,N/A,N/A\n"
  else
    print "#{email},#{result.first[:edupersonprimaryaffiliation].pop},#{result.first[:puhomedepartmentnumber].pop},#{result.first[:ou].pop}\n"
  end
end

def default_connection
  @default_connection ||=
  begin
    Net::LDAP.new(
      host: 'ldap.princeton.edu',
      base: 'o=Princeton University,c=US',
      port: 636,
      encryption: {
        method: :simple_tls,
        tls_options: OpenSSL::SSL::SSLContext::DEFAULT_PARAMS
      }
    )
  end
end

emails = File.open('email_manifest').readlines

emails.each do |email|
  print_value = ""
  email.chomp!
  find_by_email(email)
end
