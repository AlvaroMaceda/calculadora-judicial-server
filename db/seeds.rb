# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Wipe countries, autonomous communities, municipalities and holidays
Country.destroy_all

spain = Country.create(name: 'Spain', code: "ES")

def seed_autonomous_communities

    require 'autonomous_community_importer'

    filename = File.join(__dir__,'seeds','autonomous_communities.csv')
    ac_importer = AutonomousCommunityImporter.new
    ac_importer.importCSV(filename)

end
seed_autonomous_communities