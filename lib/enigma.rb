require 'rubygems'
require 'bundler/setup'
require 'rack'
require 'rack/test'

module Enigma
  SERVER_KEY        = "OMGWTFBBQSteelyDanisanAmericanrockband;itscoremembersareDonaldFagenandWalterBecker.Theband'spopularitypeakedinthelate1970s,withthereleaseofsevenalbumsblendingelementsofjazz,rock,funk,R&B,andpop.[1]RollingStonemagazinehascalledthem\"theperfectmusicalantiheroesfortheSeventies.\"[2]Theband'smusicischaracterizedbycomplexjazz-influencedstructuresandharmoniesplayedbyBeckerandFagenalongwitharevolvingcastofrockandpopstudiomusicians.[1]SteelyDan's\"cerebral,wryandeccentric\"[1]lyrics,oftenfilledwithsharpsarcasm,touchuponsuchthemesasdrugs,loveaffairs,[3][4][5][6]crime,[6]andtheirtrue-to-life\"contemptofwestcoasthippies.\"[5][6]Thepairarewell-knownfortheirnear-obsessiveperfectionismintherecordingstudio,[7][8]withonenotableexamplebeingthatBeckerandFagenusedatleast42differentstudiomusicians,11engineers,andtookoverayeartorecordthetracksthatresultedin1980'sanalbumthatcontainsonlysevensongs.[9]Gauchoasafgkljsagkadsjfkkasdfl;jadskflajdsfkl;s"
  SIGNATURE_HEADER  = "X_CLETUS_SIGNATURE"

  extend self

  def signature(method, path, payload)
    message = [method, path, payload].map(&:to_s).inject(&:+)

    digest = OpenSSL::Digest::Digest.new("sha512")
    OpenSSL::HMAC.hexdigest(digest, SERVER_KEY, message).to_s
  end

  def matches?(actual_signature, method, path, payload)
    matched = true
    expected_signature = self.signature(method, path, payload)
    expected_signature.each_char.zip(actual_signature.to_s.each_char).each do |expected, actual|
      matched = false if expected != actual
    end

    matched
  end
end
