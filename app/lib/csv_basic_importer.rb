require 'csv'

class CsvBasicImporter

    def initialize()
    end

    # This method expects UTF-8 encoded files, but do not validate it
    def importCSV(csv_filename_or_io)

        csv_io = get_io_from_parameter(csv_filename_or_io)

        begin

            csv = CSV.new(csv_io, headers: true, return_headers: true, encoding: 'UTF-8')
            
            headers = csv.first
            validate_headers headers

            line = 1
            imported = 0
            ActiveRecord::Base.transaction do
                csv.each do |row|
                    line += 1                    
                    process_row row
                    imported +=1
                end
            end
        
            total_lines = line
            return ImportResults.new(total_lines, imported)

        rescue ImportError => e
            message = "Line #{line}. " + e.message
            raise ImportError.new(message)
        end
    end

    private 

    def expected_headers
        []
    end

    def process_row(row)
    end

    def get_io_from_parameter(filename_or_io)
        if is_a_file_name?(filename_or_io)
            return open_file(filename_or_io)
        else
            return filename_or_io
        end
    end

    def is_a_file_name?(parameter)
        parameter.instance_of? String
    end

    def open_file(filename)
        begin
            return File.open(filename, "r:UTF-8")
        rescue SystemCallError => e
            raise ImportError.new("Imput/Output error: #{e.message}")
        end        
    end

    def validate_headers(header)
        expected_headers.each do |column|
            if !header.include? column
                raise HeadersError.new("Missing column '#{column}'")
            end
        end
    end

    class ImportResults
        attr_reader :lines, :imported
        def initialize(lines, imported)
            @lines = lines
            @imported = imported
        end
    end

    class Error < RuntimeError
    end

    class HeadersError < Error
    end

    class ImportError < Error
    end

end