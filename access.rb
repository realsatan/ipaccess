#!/usr/bin/ruby

#读取HTML框架文件
class HTML
  def method_missing(method, *args, &block)
    begin
      f = File.open("#{method.to_s}.html","r")
    rescue
      return "<h1 class='alert'>#{method.to_s}.html failed to open!</h1>"
    end
    
    return f.read
  end
end

#写入log
def log(message)
  begin
    File.open("./log.txt", "a") do |f|
      f.puts message
    end
  rescue
    puts "Error in log: #{message}"
  end
end

#Output HTTP HEADER
require 'cgi'

cgi = CGI.new
puts cgi.header

#Output HTML HEADER
html = HTML.new
puts html.header

#用户验证
verified = false
require './users.rb'
username = cgi['username'].strip[0,20]
password = cgi['password'].strip[0,20]
user = User.new
if user.check(username, password)
  verified = true
end

if !verified
  if username == ""
    log "访问: #{cgi.remote_addr} - #{Time.now}"
  end

  if username != ""
    log "认证失败: #{cgi.remote_addr} - #{username} - #{password} - #{Time.now}"
  end
end

res = "None"
setted = false

#写入IP到allow.ip
if verified
  begin
    File.open("/etc/apache2/allow.ip", "r+") do |f|
      res =  f.read
      f.puts "\t\tallow from #{cgi.remote_addr}"
    end
    log "#{cgi.remote_addr} - #{username} - #{Time.now}"
  rescue
    puts "<p> - IP文件操作失败 -<hr>"
  end

  setted = true
end

=begin
  重启apache2
  重启失败时返回： 
"Restarting web server: apache2Action 'start' failed.\nThe Apache error log may have more information.\n failed!\n" （没有启动权限）
"Action 'configtest' failed.\nThe Apache error log may have more information.\n failed!\n" （配置文件出错）
  重启成功时返回：
"Restarting web server: apache2 ... waiting .\n"
=end
if setted 
  ret = `./restart`
  if ret =~ /^Restarting /
    unless res =~ /failed/
      restarted = true
    end
  end
end

if verified && setted && restarted
  puts html.success()
end

#OutPut HTML HEADER&FORM
if !verified
  puts html.form()
end


#Just for test
=begin
verified = verified ? "True" : "False"
setted = setted ? "True" : "False"
restarted = restarted ? "True" : "False"

puts "Verified is: #{verified}<br>"
puts "Setted is: #{setted}<br>"
puts "Restarted is: #{restarted}<br>"
puts "Username: #{cgi['username']}<br>"
puts "Password: #{cgi['password']}<br>"
=end

#End
puts html.author
puts html.footer
