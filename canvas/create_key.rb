require 'highline/import'

key              = DeveloperKey.new
key.email        = ask("Canvas Account Email:  ")     { |q| q.default = "yourname@instructure.com" }
key.user_name    = ask("Canvas Account User Name:  ") { |q| q.default = "yourname" }
key.redirect_uri = ask("Application Redirect URI:  ") { |q| q.default = "http://localhost:3001/canvas_oauth" }

key.account      = if channel = CommunicationChannel.find_by_path(key.email)
                     channel.user.account
                   else
                     Account.default
                   end
key.save!

puts "-"*80
puts "PUT THE FOLLOWING LINES IN ROLL CALL'S config/canvas.yml"
puts "  key: #{key.id}"
puts "  secret: #{key.api_key}"
puts "-"*80
