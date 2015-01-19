#!/usr/bin/ruby

class User

  attr_accessor :users, :pass
  
  def initialize()
    @pass = Hash.new

    #打开配置文件，生成用户密码对
    @pass = {
      "satan" => "123456",
    }

  end

  def add(username, password)
    @pass[username] = password.to_s
  end

  def check(username, password)
    if username != nil && password != nil
      return @pass[username] == password.to_s
    else
      return false
    end
  end

end
