describe "Application" do

  it "should return json" do
    get '/1'
    last_response.headers['Content-Type'].must_equal 'application/json;charset=utf-8'
  end 

  it "should return the correct message as json" do
    get '/1'
    item = { status: 'ok', message: 1 }
    item.to_json.must_equal last_response.body
  end

end