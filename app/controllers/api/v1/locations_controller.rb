module Api
  module V1
    class LocationsController < InheritedResources::Base
      include ActionView::Helpers::NumberHelper
      respond_to :json
      has_scope :by_location_name, :by_location_id, :by_machine_id, :by_machine_name, :by_city_id, :by_zone_id, :by_operator_id, :by_type_id, :by_at_least_n_machines_city, :by_at_least_n_machines_zone, :by_at_least_n_machines_type, :region

      api :POST, '/api/v1/locations/suggest.json', 'Suggest a new location to add to the map'
      description "This doesn't actually create a new location, it just sends location information to region admins"
      param :region_id, Integer, :desc => 'ID of the region that the location belongs in', :required => true
      param :location_name, String, :desc => 'Name of new location', :required => false
      param :location_street, String, :desc => 'Street address of new location', :required => false
      param :location_city, String, :desc => 'City of new location', :required => false
      param :location_state, String, :desc => 'State of new location', :required => false
      param :location_zip, String, :desc => 'Zip code of new location', :required => false
      param :location_phone, String, :desc => 'Phone number of new location', :required => false
      param :location_website, String, :desc => 'Website of new location', :required => false
      param :location_operator, String, :desc => 'Machine operator of new location', :required => false
      param :location_machines, String, :desc => 'List of machines at new location', :required => false
      param :submitter_name, String, :desc => 'Name of submitter', :required => false
      param :submitter_email, String, :desc => 'Email address of submitter', :required => false
      formats [ 'json' ]
      def suggest
        region = Region.find(params['region_id'])

        send_new_location_notification(params, region)
        return_response("Thanks for entering that location. We'll get it in the system as soon as possible.", 'msg')

        rescue ActiveRecord::RecordNotFound
          return_response('Failed to find region', 'errors')
      end

      api :GET, '/api/v1/region/:region/locations.json', 'Fetch locations for a single region'
      description 'This will also return a list of machines at each location'
      param :region, String, :desc => 'Name of the Region you want to see events for', :required => true
      param :by_location_name, String, :desc => 'Name of location to search for', :required => false
      param :by_location_id, Integer, :desc => 'Location ID to search for', :required => false
      param :by_machine_id, Integer, :desc => 'Machine ID to find in locations', :required => false
      param :by_machine_name, String, :desc => 'Find machine name in locations', :required => false
      param :by_city_id, String, :desc => 'City to search for', :required => false
      param :by_zone_id, Integer, :desc => 'Zone ID to search by', :required => false
      param :by_operator_id, Integer, :desc => 'Operator ID to search by', :required => false
      param :by_type_id, Integer, :desc => 'Location type ID to search by', :required => false
      param :by_at_least_n_machines_type, Integer, :desc => 'Only locations with N or more machines', :required => false
      formats [ 'json' ]
      def index
        locations = apply_scopes(Location).order('locations.name')
        return_response(locations,'locations',[:location_machine_xrefs])
      end

      api :PUT, '/api/v1/locations/:id.json', 'Update attributes on a location'
      param :id, Integer, :desc => 'ID of location', :required => true
      param :description, String, :desc => 'Description of location', :required => false
      param :website, String, :desc => 'Website of location', :required => false
      param :phone, String, :desc => 'Phone number of location', :required => false
      param :location_type, Integer, :desc => 'ID of location type', :required => false
      formats [ 'json' ]
      def update
        location = Location.find(params[:id])

        description = params[:description]
        website = params[:website]
        phone = params[:phone]
        location_type = params[:location_type]

        if (description)
          location.description = description
        end

        if (website)
          location.website = website
        end

        if (phone)
          phone.gsub!(/\s+/, "")
          phone.gsub!(/[^0-9]/, "")

          phone = phone.empty? ? 'empty' : number_to_phone(phone)
          location.phone = phone
        end

        if (location_type)
          type = LocationType.find(location_type)
          location.location_type = type
        end

        if (location.save)
          return_response(location, 'location')
        else
          return_response(location.errors.full_messages, 'errors')
        end

        rescue ActiveRecord::RecordNotFound
          return_response('Failed to find region', 'errors')
      end

    end
  end
end
