# frozen_string_literal: true

require 'httparty'

class ApiClient
  class APIError < StandardError; end

  BASE_URL = 'https://www.thetrainline.com'

  def self.journeys(path, body)
    url = build_url(path)
    response = HTTParty.post(url,  headers: headers, body: body.to_json)
    
    return local_data if response.code == 403
    return response.parsed_response if response.success?

    raise APIError, "Status: #{response.code} - #{response.message}.\n Response: #{response.body}"
  end

  def self.locations(path, query)
    url = build_url(path)
    response = HTTParty.get(url, query: query)

    return response.parsed_response if response.success?

    raise APIError, "Status: #{response.code} - #{response.message}.\n Response: #{response.body}"
  end

  private

  def self.build_url(path)
    URI.join(BASE_URL, path).to_s
  end

  def self.headers
    {
      'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:130.0) Gecko/20100101 Firefox/130.0',
      'Accept-Language' => 'en-GB',
      'Content-Type' => 'application/json',
      'x-version' => '4.38.29729',
      'Connection' => 'keep-alive',
      'Cookie' => "#{datadome_cookie}; eupubconsent-v2=CQF6ZfAQF6ZfAAcABBENBJFgAAAAAAAAAChQAAAAAAAA.YAAAAAAAAAAA; OptanonAlertBoxClosed=2024-10-03T08%3A17%3A47.052Z; OptanonConsent=isGpcEnabled=0&datestamp=Fri+Oct+04+2024+14%3A41%3A53+GMT%2B0200+(Central+European+Summer+Time)&version=202408.1.0&browserGpcFlag=0&isIABGlobal=false&hosts=&consentId=d2670a0c-366c-4129-853e-389f85a3e092&interactionCount=1&isAnonUser=1&landingPath=NotLandingPage&groups=C0001%3A1%2CC0004%3A0%2CC0002%3A0%2CC0003%3A0%2CC0008%3A0%2CV2STACK42%3A0&genVendors=&geolocation=DE%3BBY&AwaitingReconsent=false; OTAdditionalConsentString=1~; tl_sid=s%3Afbb8baad-80a4-452c-a734-243016f52725.JvEZ4dPDfmcX7ghkmxjHPashJuJLBZ%2BhUtbwlsESHpE; TLCookieConsent=isGpcEnabled%3D0%26datestamp%3DThu%2BOct%2B03%2B2024%2B10%3A17%3A47%2BGMT%2B0200%2B(Central%2BEuropean%2BSummer%2BTime)%26version%3D202402.1.0%26browserGpcFlag%3D0%26isIABGlobal%3Dfalse%26hosts%3DH56%3A1%2CH79%3A1%2CH37%3A1%2CH45%3A1%2CH51%3A1%2CH159%3A1%2CH75%3A0%2CH76%3A1%2CH3%3A0%2CH145%3A0%2CH155%3A0%2CH11%3A0%2CH62%3A0%2CH35%3A0%2CH148%3A0%2CH69%3A0%2CH14%3A0%2CH149%3A0%2CH137%3A0%2CH96%3A0%2CH23%3A0%2CH78%3A0%2CH4%3A0%2CH70%3A0%2CH88%3A0%2CH64%3A0%2CH19%3A0%2CH77%3A0%2CH80%3A0%2CH6%3A0%2CH81%3A0%2CH7%3A0%2CH105%3A0%2CH12%3A0%2CH140%3A0%2CH42%3A0%2CH136%3A0%2CH48%3A0%2CH89%3A0%2CH22%3A0%2CH57%3A0%26consentId%3Dd2670a0c-366c-4129-853e-389f85a3e092%26interactionCount%3D1%26isAnonUser%3D1%26landingPath%3DNotLandingPage%26groups%3DC0001%3A1%2CC0004%3A0%2CC0002%3A0%2CC0003%3A0%2CC0008%3A0%2CV2STACK42%3A0%26genVendors%3D%23tl-cookie-expires%3DFri%20Oct%2003%202025%2010%3A17%3A47%20GMT%2B0200%20(Central%20European%20Summer%20Time); TLCookieConsentTCF2=CQF6ZfAQF6ZfAAcABBENBJFgAAAAAAAAAChQAAAAAAAA.YAAAAAAAAAAA%23tl-cookie-expires%3DFri%20Oct%2003%202025%2010%3A17%3A47%20GMT%2B0200%20(Central%20European%20Summer%20Time); AffiliateCode=NOT_SPECIFIED; context_id=717caaa2-302c-4729-8d43-601f1f3fcf74; currency_code=EUR; currency_value=EUR; customerUserCountry=DE; dpi-GEGHM9IE5S5VJGANI6L6ACOUE=%7B%22passengers%22%3A%5B%7B%22dob%22%3A%221989-10-04%22%2C%22id%22%3A%22pid-0%22%7D%5D%7D; pdt=6f224a79-63c9-4b48-9dad-782da6af1d5f; pref_lang=en-us; ravelinDeviceId=rjs-2ecbb911-aff0-4427-b6cf-104cad252ed3; ravelinSessionId=rjs-2ecbb911-aff0-4427-b6cf-104cad252ed3:34c8789a-9501-401c-be83-64a7df78593a; SL_G_WPT_TO=en; SL_GWPT_Show_Hide_tmp=1; SL_wptGlobTipTmp=1; webToAppCampaign=%5B%5D"
    }
  end

  def self.datadome_cookie
    ENV['COOKIE']
  end

  def self.local_data
    puts 'LOCAL DATA LOADING...'
    puts 'JOURNEY: Munich - Karlovac on 8th Oct 2024.'
    
    JSON.parse(File.read('spec/fixtures/journey_search_response.json'))
  end
end
