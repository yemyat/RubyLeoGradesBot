require 'rubygems' if RUBY_VERSION < '1.9'
require 'sinatra'
require 'typhoeus'

class LeoGradeBot < Sinatra::Base
  post '/' do
    if params.nil?
      "Hello from LEO Grades Retriever bot! 
      This bot will get the latest grades for all your modules.
      I do not store your credentials."
    else
      case params[:step].to_i
      when 1
        "What is your Student ID? (e.g. 44000)"
      when 2
        "What is your password?"
      when 3
        result = ""
        grades = getGrades(params['value1'],params['value2'])
        grades.each do |grade|
          result += "Problem "+grade["problem"].to_s+" : "+grade["grade"].to_s+"\n"
        end
        result
  end
  
  get '/:student_id/:password' do
    result = ""
    grades = getGrades(params[:student_id],params[:password])
    grades.each do |grade|
      result += "Problem "+grade["problem"].to_s+" : "+grade["grade"].to_s+"<br/>"
    end
    result
  end

  def getGrades(username, password)
    response_grades = []
    hydra = Typhoeus::Hydra.new
    courses_request = Typhoeus::Request.new("http://leo.rp.edu.sg/workspace/studentGrades.asp", 
                                      :username=>"RP\\"+username, :password=>password,
                                      :auth_method=>:ntlm)
    courses_request.on_complete do |response|
        #get problem and grade
        problems_list = (response.body).scan(/Problem ([1-9]{1,2})/)
        grades_list = (response.body).scan(/'_blank'>([ABCDFX])</)
        for i in (0..problems_list.length)
          unless problems_list[i] == nil
            response_grades[i] = {"problem" => problems_list[i], "grade" => grades_list[i]}
          end
        end
        return response_grades
    end
    hydra.queue courses_request
    hydra.run
  end

end