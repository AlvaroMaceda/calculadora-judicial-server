require 'rails_helper'
require 'date'

# You can generate calendars with ncalc:
#  export LANG=en_US.utf-8
#  ncal -M -C -d 2018-10
describe DeadlineCalculator do

    it 'instantiates' do
        calculator = DeadlineCalculator.new(create(:country))
        expect(calculator).not_to be nil
    end
    
    xcontext 'no holidays' do

        let(:country_withouth_holidays) {create(:country)}
        let(:calculator) { DeadlineCalculator.new(country_withouth_holidays) }
        let(:a_working_week) { 5*1 }
        let(:two_working_weeks) { 5*2 }
        
        """
        October 2018      
        Mo Tu We Th Fr Sa Su  
         1  2  3  4  5  6  7  
         8  9 10 11 12 13 14  
        15 16 17 18 19 20 21  
        22 23 24 25 26 27 28  
        29 30 31   
        """
        it 'does not count the notification day' do
            notification_date = Date.parse('1 Oct 2018')
            days = 1
            expected_deadline = Date.parse('2 Oct 2018')

            deadline = calculator.deadline(notification_date,days)

            expect(deadline).to eq(expected_deadline)
        end
        
        it 'starts counting on monday if notified saturday' do
            a_saturday = Date.parse('20 Oct 2018')
            days = 1
            expected_deadline = Date.parse('22 Oct 2018')

            deadline = calculator.deadline(a_saturday,days)

            expect(deadline).to eq(expected_deadline)
        end

        it 'starts counting on monday if notified sunday' do
            a_saturday = Date.parse('21 Oct 2018')
            days = 1
            expected_deadline = Date.parse('22 Oct 2018')

            deadline = calculator.deadline(a_saturday,days)

            expect(deadline).to eq(expected_deadline)
        end        

        context 'deadline does not end on weekend' do
            """
                  June 2017        
            Mo Tu We Th Fr Sa Su  
                      1  2  3  4  
             5  6  7  8  9 10 11  
            12 13 14 15 16 17 18  
            19 20 21 22 23 24 25  
            26 27 28 29 30 
            """
            it 'tuesday: 3 days shift' do
                notification_date = Date.parse('13 Jun 2017')
                days = two_working_weeks + 3
                expected_deadline = Date.parse('30 Jun 2017')

                deadline = calculator.deadline(notification_date,days)

                expect(deadline).to eq(expected_deadline)
            end

            """
                    May 2017             June 2017             July 2017        
            Mo Tu We Th Fr Sa Su  Mo Tu We Th Fr Sa Su  Mo Tu We Th Fr Sa Su  
            1  2  3  4  5  6  7            1  2  3  4                  1  2  
            8  9 10 11 12 13 14   5  6  7  8  9 10 11   3  4  5  6  7  8  9  
            15 16 17 18 19 20 21  12 13 14 15 16 17 18  10 11 12 13 14 15 16  
            22 23 24 25 26 27 28  19 20 21 22 23 24 25  17 18 19 20 21 22 23  
            29 30 31              26 27 28 29 30        24 25 26 27 28 29 30  
                                                        31                            
            """
            it 'exact number of weeks' do
                notification_date = Date.parse('23 May 2017')
                days = 30
                expected_deadline = Date.parse('4 Jul 2017')

                deadline = calculator.deadline(notification_date,days)
                
                expect(deadline).to eq(expected_deadline)
            end

        end

        context 'deadline ends on weekend' do

            """
            June 2017        
            Mo Tu We Th Fr Sa Su  
                      1  2  3  4  
             5  6  7  8  9 10 11  
            12 13 14 15 16 17 18  
            19 20 21 22 23 24 25  
            26 27 28 29 30 
            """
            it 'wednesday 3 days shift' do
                notification_date = Date.parse('14 Jun 2017')
                days = a_working_week + 3
                expected_deadline = Date.parse('26 Jun 2017')

                deadline = calculator.deadline(notification_date,days)
                
                expect(deadline).to eq(expected_deadline)
            end

            it 'friday 1 day shift' do
                notification_date = Date.parse('9 Jun 2017')
                days = 1
                expected_deadline = Date.parse('12 Jun 2017')
                
                deadline = calculator.deadline(notification_date,days)
                
                expect(deadline).to eq(expected_deadline)
            end

        end

    end

    context 'holidays' do 

        before(:each) do
            Spain.create!
        end

        let(:calculator) { DeadlineCalculator.new(Spain.benidorm) }
        
        """
             October 2020           November 2020      
        Mo Tu We Th Fr Sa Su  	Mo Tu We Th Fr Sa Su  
                  1  2  3  4  	                   1  
         5  6  7  8  9 10 11  	 2  3  4  5  6  7  8  
        12 13 14 15 16 17 18  	 9 10 11 12 13 14 15  
        19 20 21 22 23 24 25  	16 17 18 19 20 21 22  
        26 27 28 29 30 31     	23 24 25 26 27 28 29  
                                30  

        Holidays
        ------------------------------------------------
        Country: 1 Jan, 10 Apr, 1 May, 15 Aug, 12 Oct, 8 Dec, 25 Dec
        Valencian Community: 6 Jan, 19 March, 13 Apr, 9 Oct, 7 Dec
        Benidorm: 9 Nov, 10 Nov
        (see factories/spain.rb for holiday definitions)
        """
        xit 'skips a country\'s holiday'  do
            # Holidays: 
            #     9 Nov 2019 (municipality)
            #    10 Nov 2019 (municipality)
            notification_date = Date.parse('21 Oct 2019')
            days = 20
            expected_deadline = Date.parse('19 Nov 2019')

            deadline = calculator.deadline(notification_date,days)
            
            expect(deadline).to eq(expected_deadline)            
        end

        """
        November 2019         December 2019          January 2020      
        Mo Tu We Th Fr Sa Su  Mo Tu We Th Fr Sa Su  Mo Tu We Th Fr Sa Su  
                     1  2  3                     1         1  2  3  4  5  
         4  5  6  7  8  9 10   2  3  4  5  6  7  8   6  7  8  9 10 11 12  
        11 12 13 14 15 16 17   9 10 11 12 13 14 15  13 14 15 16 17 18 19  
        18 19 20 21 22 23 24  16 17 18 19 20 21 22  20 21 22 23 24 25 26  
        25 26 27 28 29 30     23 24 25 26 27 28 29  27 28 29 30 31        
                              30 31      
    
        Holidays
        ------------------------------------------------
        Country: 1 Nov, 6 Dec, 8 Dec, 25 Dec
        Valencian Community: 18 March, 13 Apr, 12 Oct, 7 Dec
        Benidorm: 9 Nov, 10 Nov
        (see factories/spain.rb for holiday definitions)                                
        """
        xit 'skips country and autonomous community holidays' do
            notification_date = Date.parse('26 Nov 2019')
            days = 20
            expected_deadline = Date.parse('3 Jan 2019')

            deadline = calculator.deadline(notification_date,days)
            
            expect(deadline).to eq(expected_deadline)            
        end

        xit 'skips country, autonomous community and municipality holidays' do
        end

        xit 'WHAT HAPPENS IF A HOLIDAY IS IN WEEKEND?' do
        end

    end

end
