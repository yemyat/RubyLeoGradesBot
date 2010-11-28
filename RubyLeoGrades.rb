require 'rubygems'
require 'typhoeus'

  def getGrades(username, password)
    response_grades = []
    hydra = Typhoeus::Hydra.new
    courses_request = Typhoeus::Request.new("http://leo.rp.edu.sg/workspace/studentGrades.asp", 
                                      :username=>"RP\\"+username, :password=>password,
                                      :auth_method=>:ntlm, :verbose=>true)
    courses_request.on_complete do |response|
        #get problem and grade
        problems_list = (response.body).scan(/Problem ([1-9]{1,2})/)
        grades_list = (response.body).scan(/'_blank'>([ABCDFX])</)
        for i in (0..problems_list.length)
          unless problems_list[i] == nil
            response_grades[i] = {"problem" => problems_list[i], "grade" => grades_list[i]}
          end
        end
        puts response_grades
        return response_grades
    end
    hydra.queue courses_request
    hydra.run
  end

getGrades('91224','iloveJE16122009')