# Trainline Bot
Bot that triggers searches on http://thetrainline.com and returns the results in a specific format.

## Usage

Open terminal and clone the repo:
```bash
git clone git@github.com:Cato81/trainline_bot.git
cd trainline_bot
```

**Testing with Local data**

If you want to test the bot with local data which will always return the same set of result.

Load the irb session

```bash
irb -r ./lib/com_thetrainline.rb
```
After irb session is loaded trigger the search:

```ruby
ComTheTrainline.find('Munich', 'Karlovac', DateTime.new(2024, 10, 8))
```

The result should be printed in following format
```ruby
[{:departure_station=>"München Ost",
  :departure_at=>#<DateTime: 2024-10-08T23:55:00+02:00 ((2460592j,78900s,0n),+7200s,2299161j)>,
  :arrival_station=>"Karlovac Central Bus Station",
  :arrival_at=>#<DateTime: 2024-10-09T14:25:00+02:00 ((2460593j,44700s,0n),+7200s,2299161j)>,
  :service_agencies=>["ÖBB", "Autotrans by Arriva"],
  :duration_in_minutes=>870,
  :changeover=>1,
  :products=>["train", "bus"],
  :fares=>
   [{:name=>"Sparschiene inkl. Reservierung", :price_in_cents=>"11490", :currency=>"EUR", :comfort_class=>2},
    {:name=>"Sparschiene inkl. Reservierung", :price_in_cents=>"37490", :currency=>"EUR", :comfort_class=>2},
    {:name=>"Sparschiene inkl. Reservierung", :price_in_cents=>"20490", :currency=>"EUR", :comfort_class=>2},
    {:name=>"Autotrans by Arriva", :price_in_cents=>"610", :currency=>"EUR", :comfort_class=>2}]}]
```

**Testing with trainline data**

In case you want to test the bot with real data you will need to do some manual steps

In terminal start irb session and run following:
```ruby
require 'httparty'
url = 'https://www.thetrainline.com/api/journey-search/'
headers = {
	'Content-Type' => 'application/json',
	'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/85.0.4183.121 Safari/537.36',
	'Accept' => 'application/json'
	}
response = HTTParty.post(url, headers: headers,body: {})
response['url']
```
Copy the url and exit the irb session

Paste the url into your browser and navigate to it

Open Network monitor in dev tools and resolve the CAPTCHA

In response tab copy the value of the cookie attribute

In terminal set the COOKIE ENV with copied value
```bash
export ENV['COOKIE'] = "<your-copied-value>"
irb -r ./lib/com_thetrainline.rb
```
After irb session is loaded you can now trigger search.

*NOTE: you will need to renew CAPTCHA cookie after several hours*
