#!perl 
use strict;
use warnings;
use Test::More;        
use Test::Exception;        
use HoN::Client::Chat::PacketFactory;

plan 'no_plan';

# use
BEGIN {
    use_ok( 'HoN::Client::Chat::Packet::JoinChannel' ) || print "Bail out!";
}

# instace
my $factory = HoN::Client::Chat::PacketFactory->new;

# JoinChannel
my $pkt_join = $factory->encode_packet('JoinChannel', { channel => 'Cambada' });

isa_ok($pkt_join, 'HoN::Client::Chat::Packet::JoinChannel', 'JoinChannel - thing returned by encode_packet()');
is($pkt_join->packed, pack( 'H*', '1e0043616d6261646100'), 'JoinChannel - right packed data');

is($pkt_join->event_name, 'join_channel_request', 'event name');



# Join Channel Response
my $data =  '486F4E203400740000001857656C636F6D6520746F204865726F6573206F66204E657765727468210003000000123A2E00044A863000045EA7300004310000004475647572697300610B050003000077686974650054726F6C6C2046616365004B69646479006EF4000003006272617A696C0077686974650044656661756C742049636F6E005375746174004F4013000300000044656661756C742049636F6E004D414E545241494E00836A0900030072757373696100776869746500446572700056616E616479720035372E000300756E697465647374617465730077686974650057617465720050726965737465737300D501320003000077686974650044656661756C742049636F6E00536174617269757300683600000300756E69746564737461746573007768697465004C65616600616C7761797368617070790021822E0003006368696E6100776869746500526963657200536872696D705F526F636B00A94C330003000077686974650044656661756C742049636F6E00574F4F42455254009F6C1300034000676F6C64736869656C64005A6F6D626965004765744F737400D03F010003000077686974650044656661756C742049636F6E004950484F4E45686F6D65008BC10E0003000077686974650044656661756C742049636F6E00754E73756E476865724F6000BEF231000300007768697465004865617274204A6170616E00566F6C63614E696969634B00F9910C00030062656C6769756D00776869746500695761726400426F73636F76696368003B8F000003406272617A696C00676F6C64736869656C640044656661756C742049636F6E0078447265616D5F4B657A7A6100F5980E0003000077686974650044656661756C742049636F6E006F676776616C6400643B150003000077686974650044656661756C742049636F6E00506F67736C616D6D6572005DBA330003000077686974650044656661756C742049636F6E004A696E42520012D1320003006272617A696C006469616D6F6E6400536E6F77626F61726465720054726F706963616C002349320003000077686974650044656661756C742049636F6E007A4C7563696C657A00506D310003000077686974650044656661756C742049636F6E006E6166755F0079B9300003006E6F7277617900776869746500313732302049524C005468655068756B6E446F43003313160003000077686974650044656661756C742049636F6E004A6F6E6B6B69009348190003004465766F7572657200776869746500596F757220536F756C206973204D696E650074686F726265617200F79D170003000077686974650044656661756C742049636F6E004D616C756D61646572006FA9330003000077686974650044656661756C742049636F6E00424C554E545A00536F330003000077686974650044656661756C742049636F6E0042655F4D795F42697463680080842F0003000077686974650044656661756C742049636F6E0044656D6B7900D1202A00030000776869746500416E6F6E0044656669616E63654A52009B841C0003000077686974650044656661756C742049636F6E004C75636B65643700284B14000300756E6974656473746174657300776869746500537570706F72742050726F005472756D7079313233009B2F110003000077686974650044656661756C742049636F6E00636F636F7265656E6100E1EF320003000077686974650044656661756C742049636F6E0046496173687A00F3BB290003000077686974650044656661756C742049636F6E005477696E7A6C6500285F31000300756E697465647374617465730077686974650054726F6C6C2046616365004D6179303600D7790A00034000676F6C64736869656C6400526167652046616365006963656D616E313332340060AB330003000077686974650044656661756C742049636F6E005465727056656E64657474610008C3330003000077686974650044656661756C742049636F6E00536D6165676F6C0003D52D000300756E697465647374617465730077686974650041697200636972637569746865726F00F24217000300756B7261696E65007768697465004361720073756E616D6900A601300003000077686974650044656661756C742049636F6E00646469737070717100B3111E0003000077686974650044656661756C742049636F6E005A616E74686F7269616E0095592E000300007768697465004F6E206120476F6174004B617A616D696173005DFF1100030000776869746500536E6F77626F61726465720052616D6F6E436F7274657A00A50F11000300000044656661756C742049636F6E006D65646C616300499A110003000077686974650044656661756C742049636F6E004275667556656E6F6D00C97B2E0003004465766F7572657200776869746500526164696174696F6E004B6944447374616E6E00DCA20A00034000676F6C64736869656C64004361727279204D6500796B740084680400030000776869746500446F75626C65205261696E626F7700';
my $pkt = $factory->decode_packet(0x0400, pack('H*', $data));

isa_ok($pkt, 'HoN::Client::Chat::Packet::JoinChannel', 'JoinChannelResponse- thing returned by encode_packet()');

is($pkt->channel, 'brasil', 'channel');
is($pkt->channel_id, 'brasil', 'channel');