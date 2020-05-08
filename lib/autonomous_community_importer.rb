require 'csv'

class AutonomousCommunityImporter

    def initialize(country)
        @country = country
    end

    def importCSV(csv_file)
        begin
            csv = CSV.new(csv_file, headers: true, return_headers: true)            
            
            headers = csv.first
            validate_headers headers

            csv.each do |row|
                create_autonomous_community row
            end        

        rescue ImportError => e
            message = "Line #{csv.lineno}. " + e.message
            raise ImportError.new(message)
        end
    end

    private

    def validate_headers(headers)
        columns = headers.to_h.keys
        if !columns.include? 'code'
            raise HeadersError.new("Missing column 'code'")
        end
        if !columns.include? 'name'
            raise HeadersError.new("Missing column 'name'")
        end
    end

    def create_autonomous_community(row_data)
        begin
            curated_row = {
                country_id: @country.id,
                name: row_data['name'],
                code: row_data['code']
            }
            ac = AutonomousCommunity.create!(curated_row.to_h)
        rescue ActiveRecord::RecordInvalid => e
            message = <<~HEREDOC
                Error creating autonomous community: 
                #{row_data.to_s.chomp}
                #{curated_row.except(:country_id)}
                #{e.message}
            HEREDOC
            
            raise ImportError.new(message)
        end
    end

    class HeadersError < RuntimeError
    end

    class ImportError < RuntimeError
    end

end