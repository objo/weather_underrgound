class WelcomeController < ApplicationController
  def test
    response = HTTParty.get("http://api.wunderground.com/api/#{ENV['wunderground_api_key']}/geolookup/conditions/q/OH/Columbus.json")

    @location = response['location']['city']
    @temp_f = response['current_observation']['temp_f']
    @temp_c = response['current_observation']['temp_c']
    @weather_icon = response['current_observation']['icon_url']
    @weather_words = response['current_observation']['weather']
    @forecast_link = response['current_observation']['forecast_url']
    @real_feel = response['current_observation']['feelslike_f']
  end

  def index
    # Creates an array of states that our user can choose from on our index page
    @states = %w(HI AK CA OR WA ID UT NV AZ NM CO WY MT ND SD NB KS OK
		 TX LA AR MO IA MN WI IL IN MI OH KY TN MS AL GA FL SC NC VA WV DE MD PA NY
		 NJ CT RI MA VT NH ME DC).sort!

    # removes spaces from the 2-word city names and replaces the space with an underscore
    if params[:city] != nil
      params[:city].gsub!(" ", "_")
    end

    #checks that the state and city params are not empty before calling the API
    if params[:state].present? && params[:city].present?

      if Location.find_by(city: params[:city], state: params[:state])
        location = Location.find_by(city: params[:city], state: params[:state])
      else
	       results = HTTParty.get("http://api.wunderground.com/api/#{Figaro.env.wunderground_api_key}/geolookup/conditions/q/#{params[:state]}/#{params[:city]}.json")

         location = Location.create(city: params[:city], state: params[:state], response: results)

      end
      # if no error is returned from the call, we fill our instants variables with the result of the call
      if location.results['response']['error'] == nil || location.results['error'] ==""
  	    @location = location.results['location']['city']
  	    @temp_f = location.results['current_observation']['temp_f']
  	    @temp_c = location.results['current_observation']['temp_c']
        @weather_icon = location.results['current_observation']['icon_url']
        @weather_bare_icon = location.results['current_observation']['icon']
  	    @weather_words = location.results['current_observation']['weather']
        @forecast_link = location.results['current_observation']['forecast_url']
  	    @real_feel_f = location.results['current_observation']['feelslike_f']
  	    @real_feel_c = location.results['current_observation']['feelslike_c']
  	 else
       # if there is an error, we report it to our user via the @error variable
  	   @error = location.results['response']['error']['description']
     end
   end
 end
end
