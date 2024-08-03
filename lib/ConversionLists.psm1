# During update:
# In which files the update script should add index at the start of
# the updated strings?
#
# E.g. Old translation string = "String A"
#      New translation string = "91_String B" where 91 is index
$global:UPDATE_ADD_INDEX = @(
    'addon', 'lobby', 'error'
)

# What quest files should be included. The quest files are considered
# to be files in game folders:
#   exd/cut_scene
#   exd/opening
#   exd/quest
# Each entry in the list should be an EXH file name w/o '.exh', e.g. 'jobdrg300_01067'
$global:QUEST_INCLUDE_LIST = @(
    # 2.0 - A Realm Reborn
    #  Opening cutscene + Gridania
    'manfst000_00083',
    #   Gridania
    'manfst050_00540', 'openinggridania', 'manfst001_00039', 'manfst002_00085',
    'manfst003_00123', 'manfst004_00124', 'subfst010_00001', 'subfst005_00028',
    'subfst045_00201', 'manfst005_00445', 'subfst034_00128', 'xxafst034_03854',
    'subfst038_00175', 'subfst038_00175', 'xxafst031_03855', 'subfst035_00129',
    'subfst027_00176', 'subfst049_00376', 'subfst056_00377', 'subfst058_00379',
    'subfst059_00380', 'subfst060_00381', 'subfst068_00384', 'subfst073_00387',
    'subfst055_00161', 'manfst006_00446', 'manfst007_00447', 'manfst008_00448',
    'manfst009_00449', 'manfst200_00507', 'manfst201_00508', 'subwil141_00674',
    #    Limsa
    'mansea000_00541', 'mansea050_00542', 'openinglimsalominsa', 'mansea001_00107',
    'mansea002_00108', 'mansea003_00109', 'subsea001_00111', 'subsea050_00462',
    'subsea051_00463', 'mansea005_00543', 'subsea053_00465', 'subsea054_00466',
    'subsea055_00467', 'subsea056_00468', 'subsea057_00469', 'subsea100_00397',
    'subsea105_00402', 'subsea106_00403', 'subsea109_00406', 'subsea115_00412',
    'subsea118_00415', 'subsea116_00413', 'subsea117_00414', 'mansea006_00689',
    'mansea007_00544', 'mansea008_00690', 'mansea009_00545', 'mansea200_00546',
    'mansea201_00526',
    #    Ul'dah
    'manwil000_00548', 'manwil050_00549', 'openinguldah', 'manwil001_00594',
    'manwil002_00568', 'manwil003_00569', 'manwil004_00570', 'subwil027_00595',
    'subwil025_00671', 'manwil005_00550', 'subwil060_00303', 'xxawil063_03852',
    'subwil064_00307', 'subwil066_00320', 'subwil026_00623', 'subwil080_00328',
    'subwil095_00503', 'subwil081_00329', 'subwil082_00330', 'xxawil083_03853',
    'subwil084_00332', 'subwil085_00333', 'subwil086_00334', 'subwil088_00336',
    'manwil006_00628', 'manwil007_00551', 'manwil008_00641', 'manwil009_00552',
    'manwil200_00528', 'manwil202_00529', 'subfst102_00673',
    #   Ifrit arc
    'manfst203_00675', 'mansea203_00245', 'subsea150_00676', 'manfst204_00677',
    'subfst103_00678', 'manfst205_00660', 'manfst206_00509', 'manfst207_00510',
    'subwil110_00618', 'subwil111_00619', 'subwil112_00620', 'subwil113_00621',
    'subwil114_00622', 'subwil129_00574', 'manfst208_00272', 'manfst209_00343',
    'manfst300_00511',
    #   GC Choice
    #    Twin Adder
    'manfst302_00680', 'manfst303_00683', 'subfst120_00700',
    #    Maelstrom
    'mansea302_00681', 'mansea303_00684', 'subsea910_00701',
    #    Immortal Flames
    'manwil302_00682', 'manwil303_00685', 'subwil160_00702',
    #   Sylph arc
    'manfst304_00513', 'xxausa002_03856', 'gaiusa003_00709', 'gaiusa004_00710',
    'gaiusa101_00715', 'xxausa103_03857', 'xxausa104_03858', 'gaiusa105_00719',
    'gaiusa201_00724', 'gaiusa202_00725', 'xxausa203_03859', 'xxausa301_03860',
    'xxausa302_03861', 'gaiusa305_00737', 'gaiusa306_00738', 'gaiusa308_00740',
    'xxausa308_03862', 'manfst306_00514', 'gaiusa401_00743', 'gaiusa402_00744',
    'gaiusa404_00746',
    #   Lahabrea arc
    'gaiusa405_00747', 'gaiusa404_00746', 'gaiusa406_00748', 'gaiusa504_00756',
    'gaiusa505_00757', 'gaiusa509_00761', 'gaiusa510_00762', 'gaiusa601_00763',
    'gaiusa603_00765', 'gaiusa701_00774', 'gaiusa702_00775', 'gaiusa703_00776',
    'gaiusa704_00777', 'gaiusa705_00778', 'gaiusa709_00782', 'gaiusa710_00783',
    'xxausa711_03863', 'xxausa801_03864', 'gaiusa803_00787', 'gaiusa802_00786',
    'gaiusa904_00799', 'gaiusa905_00800', 'gaiusa906_00801',
    #   Titan arc
    'manfst309_00516', 'gaiusb002_00809', 'gaiusb003_00810', 'gaiusb004_00811',
    'gaiusb005_00812', 'gaiusb007_00814', 'xxausb012_03865', 'gaiusb102_00821',
    'gaiusb103_00822', 'gaiusb112_00831', 'gaiusb201_00832', 'xxausb208_03866',
    'gaiusb209_00840', 'gaiusb212_00843', 'gaiusb304_00845', 'gaiusb305_00846',
    'gaiusb307_00848', 'gaiusb309_00850', 'gaiusb314_00855', 'gaiusb315_00856',
    'gaiusb401_00857',
    #   Garuda arc
    'manfst313_00517', 'xxausb503_03867', 'gaiusb507_00876', 'gaiusb509_00878',
    'manfst401_00518', 'gaiusb601_00883', 'gaiusb602_00884', 'gaiusb604_00886',
    'gaiusb605_00887', 'gaiusb607_00889', 'gaiusb608_00890', 'gaiusb702_00897',
    'gaiusb801_00910', 'gaiusb802_00911', 'gaiusb803_00912', 'xxausb808_03868',
    'gaiusb901_00924', 'gaiusb904_00927', 'xxausb914_03869', 'gaiusc001_00938',
    'gaiusc002_00939', 'gaiusc003_00940', 'gaiusc004_00941', 'gaiusc101_00952',
    'gaiusc102_00953', 'gaiusc104_00955', 'gaiusc105_00956', 'gaiusc108_00959',
    'gaiusc201_00960', 'gaiusc202_00961', 'gaiusc203_00962', 'gaiusc204_00963',
    'gaiusc208_00967', 'xxausc307_03870', 'gaiusc308_00975', 'manfst404_00519',
    'manfst405_00520',
    #   Gaius arc + Finale
    'gaiusc403_00978', 'gaiusc405_00980', 'gaiusc406_00981', 'gaiusc407_00982',
    'gaiusc408_00983', 'gaiusc409_00984', 'gaiusc411_00986', 'gaiusc601_01001',
    'gaiusc602_01002', 'xxausc603_03871', 'gaiusc604_01004', 'gaiusc605_01005',
    'manfst407_00521', 'manfst408_00522', 'gaiusc901_01036', 'xxcusc901_04521',
    'gaiusc902_01037', 'xxausc908_03872', 'manfst502_01136', 'xxafst502_03873',
    'manfst503_00524', 'xxcfst503_04522', 'manfst600_00525',
    #  2.1
    'gaiuse101_01175', 'gaiuse102_01176', 'xxause103_03874', 'gaiuse104_01178',
    'xxause104_03875', 'gaiuse106_01180', 'xxause106_03876', 'gaiuse105_01179',
    'gaiuse114_01188', 'xxause114_03877', 'gaiuse115_01189', 'gaiuse116_01190',
    'gaiuse117_01191', 'gaiuse118_01192', 'gaiuse119_01193', 'xxause119_03878',
    #  2.2
    'voiceman_02200', 
    'gaiuse201_01345', 'xxause201_03879', 'gaiuse202_01346', 'gaiuse203_01347',
    'gaiuse204_01348', 'xxause204_03880', 'gaiuse206_01350', 'xxause206_03881',
    'gaiuse208_01352', 'gaiuse209_01353', 'xxause211_03882', 'gaiuse212_01356',
    'gaiuse214_01358', 'gaiuse215_01359', 'gaiuse216_01360', 'gaiuse217_01361',
    'gaiuse218_01362', 'gaiuse219_01363',
    #  2.3
    'voiceman_02300',
    'gaiuse301_01442', 'gaiuse302_01443', 'gaiuse303_01444', 'xxause303_03883',
    'gaiuse304_01445', 'xxause304_03884', 'gaiuse305_01446', 'gaiuse306_01447',
    'gaiuse307_01448', 'gaiuse311_01452', 'xxause311_03885', 'gaiuse312_01453',
    'gaiuse315_01456', 'gaiuse316_01457', 'gaiuse317_01458', 'gaiuse318_01459',
    'gaiuse319_01460',
    #  2.4
    'voiceman_02400',
    'gaiuse401_00052', 'gaiuse402_00053', 'gaiuse403_00054', 'gaiuse404_00057',
    'gaiuse405_00062', 'gaiuse406_00069', 'gaiuse407_00074', 'gaiuse408_00075',
    'gaiuse409_00077', 'gaiuse410_00078', 'gaiuse411_00079', 'xxause411_03886',
    'gaiuse413_00081', 'xxause413_03887', 'gaiuse414_00082', 'gaiuse415_00084',
    'gaiuse416_00086', 'gaiuse417_00087', 'gaiuse418_00088', 'gaiuse419_00089',
    #  2.5
    'voiceman_02500',
    'gaiuse501_00363', 'gaiuse502_00364', 'gaiuse503_00365', 'gaiuse504_00366',
    'gaiuse505_00367', 'xxause505_03888', 'gaiuse506_00368', 'gaiuse507_00369',
    'gaiuse508_00429',
    #  2.58
    'gaiuse601_00370', 'gaiuse602_00371', 'gaiuse603_00372', 'gaiuse604_00373',
    'gaiuse605_00391', 'gaiuse606_00418', 'gaiuse607_00419', 'xxcuse607_04591',
    'gaiuse608_00420', 'gaiuse609_00421', 'gaiuse610_00422', 'gaiuse611_00423',
    'gaiuse612_00424', 'gaiuse613_00425', 'gaiuse614_00426', 'gaiuse615_00427',
    'gaiuse616_00428',
    # 3.0 - Heavensward
    #  Part 1
    'voiceman_03001',
    'heavna101_01580', 'heavna102_01581', 'heavna103_01582', 'heavna104_01583',
    'heavna105_01584', 'heavna106_01585', 'heavna107_01586', 'heavna108_01587',
    'heavna109_01588', 'heavna110_01589', 'heavna111_01590', 'heavna112_01591',
    'heavna113_01592', 'heavna114_01593', 'heavna115_01594', 'heavna116_01595',
    'heavna117_01596', 'heavna118_01597', 'heavna119_01598', 'heavna201_01599',
    'voiceman_03002',
    'heavna202_01600', 'heavna203_01601', 'heavna301_01602',
    'voiceman_03003',
    'heavna302_01603', 'heavna303_01604', 'heavna304_01605', 'heavna305_01606',
    'heavna306_01607', 'heavna307_01608', 'heavna308_01609', 'heavna309_01610',
    'heavna310_01611', 'heavna311_01612', 'heavna312_01613', 'heavna313_01614',
    'heavna314_01615', 'heavna315_01616', 'heavna316_01617', 'heavna317_01618',
    'heavna318_01619', 'heavna319_01620', 'heavna320_01621', 'heavna321_01622',
    'heavna322_01623', 'heavna323_01624', 'heavna324_01625', 'heavna325_01626',
    'heavna326_01627',
    #  Part 2
    'heavna327_01628', 'heavna328_01629', 'heavna329_01630', 'heavna330_01631',
    'heavna331_01632', 'heavna332_01633', 'heavna333_01634', 'heavna334_01635',
    'heavna335_01636',
    'voiceman_03004',
    'heavna401_01637', 'heavna402_01638', 'heavna406_01993', 'heavna407_01994',
    'heavna408_01995', 'heavna409_01996', 'heavna403_01639', 'heavna404_01640',
    'heavna405_01641', 'heavna501_01642', 'heavna502_01643',
    'voiceman_03005',
    'heavna503_01644', 'heavna504_01645', 'heavna505_01646', 'heavna506_01647',
    'heavna507_01648', 'heavna508_01649',
    'voiceman_03006',
    'heavna601_01650', 'heavna602_01651', 'heavna603_01652', 'heavna604_01653',
    'heavna605_01654', 'heavna606_01655', 'heavna607_01656', 'heavna608_01657',
    'heavna609_01658', 'heavna610_01659', 'heavna611_01660', 'heavna612_01661',
    'heavna613_01662',
    'voiceman_03007',
    'heavna701_01663', 'heavna702_01664', 'heavna703_01665', 'heavna704_01666',
    'heavna705_01667', 'heavna706_01668',
    'voiceman_03008',
    'heavna707_01669',
    #  3.1
    'voiceman_03100',
    'heavnb101_02156', 'heavnb102_02157', 'heavnb103_02158', 'heavnb104_02159',
    'heavnb105_02160', 'heavnb106_02161', 'heavnb107_02162', 'heavnb108_02163',
    #  3.2
    'voiceman_03200',
    'heavnc101_02231', 'heavnc102_02232', 'heavnc103_02233', 'heavnc104_02234',
    'heavnc105_02235', 'heavnc106_02236', 'heavnc107_02237', 'heavnc108_02238',
    'heavnc109_02239', 'heavnc110_02240', 'heavnc111_02241',
    #  3.3
    'voiceman_03300',
    'heavnd101_02242', 'heavnd102_02243', 'heavnd103_02244', 'heavnd104_02245',
    'heavnd105_02246', 'heavnd106_02247',
    #  3.4
    'voiceman_03400',
    'heavne101_02341', 'heavne102_02342', 'heavne103_02343', 'heavne104_02344',
    'heavne105_02345', 'heavne106_02346', 'heavne107_02347', 'heavne108_02348',
    'heavne109_02349', 'heavne110_02350',
    #  3.5
    'voiceman_03500',
    'heavnf101_02351', 'heavnf102_02352', 'heavnf103_02353', 'heavnf104_02354',
    'heavnf105_02355',
    #  3.58
    'heavng101_02356', 'heavng102_02357', 'heavng103_02358', 'heavng104_02359',
    # 4.0 - Stormblood
    #  Part 1
    'voiceman_04000',
    'stmbda101_02446', 'stmbda102_02447', 'stmbda103_02448', 'stmbda104_02449',
    'stmbda105_02450', 'stmbda111_02451', 'stmbda112_02452', 'stmbda113_02453',
    'stmbda114_02454', 'stmbda121_02455', 'stmbda122_02456', 'stmbda127_02954',
    'stmbda128_02955', 'stmbda123_02457', 'stmbda124_02458', 'stmbda125_02459',
    'stmbda126_02460', 'stmbda131_02461', 'stmbdz001_02635', 'stmbdz002_02636',
    'stmbdz003_02637', 'stmbdz004_02638', 'stmbda132_02462', 'stmbda133_02463',
    'stmbda134_02464', 'stmbda135_02465', 'stmbda136_02466', 'stmbda137_02467',
    'stmbda138_02468', 'stmbda139_02469',
    'voiceman_04001',
    'stmbda201_02470', 'stmbda202_02471', 'stmbda203_02472', 'stmbda204_02473',
    'stmbda205_02474', 'stmbda206_02475', 'stmbda207_02476', 'stmbda301_02477',
    'voiceman_04002',
    'stmbda302_02478', 'stmbda303_02479', 'stmbda304_02480', 'stmbdz209_02681',
    'stmbda327_02953', 'stmbdz207_02679', 'stmbda305_02481', 'stmbda306_02482',
    'stmbda307_02483', 'stmbda308_02484', 'stmbda309_02485', 'stmbda310_02486',
    'stmbda311_02487', 'stmbda312_02488', 'stmbda313_02489', 'stmbda314_02490',
    'stmbda315_02491', 'stmbda316_02492', 'stmbda325_02934', 'stmbda317_02493',
    'stmbda318_02494', 'stmbda319_02495', 'stmbda320_02496', 'stmbda321_02497',
    'stmbda326_02935', 'stmbda322_02498', 'stmbda323_02499',
    #  Part 2
    'stmbda324_02630', 'stmbda401_02500',
    'voiceman_04003',
    'stmbda402_02501', 'stmbda403_02502', 'stmbda404_02503', 'stmbda405_02504',
    'stmbda406_02505', 'stmbda407_02506', 'stmbda408_02507', 'stmbda409_02508',
    'stmbda410_02509', 'stmbda411_02510', 'stmbda412_02511', 'stmbda413_02512',
    'stmbda414_02513', 'stmbda415_02514', 'stmbda416_02515', 'stmbda417_02516',
    'stmbda418_02517', 'stmbda419_02518',
    'voiceman_04004',
    'stmbda501_02519', 'stmbda509_02946', 'stmbda502_02520', 'stmbda503_02521',
    'stmbda510_02947', 'stmbda504_02522', 'stmbda505_02523', 'stmbda506_02524',
    'stmbda507_02525', 'stmbda508_02526', 'stmbda601_02527',
    'voiceman_04005',
    'stmbda602_02528', 'stmbda603_02529', 'stmbda604_02530', 'stmbda605_02531',
    'stmbda606_02532', 'stmbda607_02533', 'stmbda608_02534', 'stmbda609_02535',
    'stmbda610_02536', 'stmbda611_02537', 'stmbda612_02538', 'stmbda613_02539',
    'stmbda614_02540', 'stmbda615_02541', 'stmbda616_02542', 'stmbda617_02543',
    'stmbda618_02544', 'stmbda619_02545', 'stmbda620_02546', 'stmbda621_02547',
    'voiceman_04006',
    'stmbda701_02548', 'stmbda702_02549', 'stmbda703_02550', 'stmbda704_02551',
    'stmbda705_02552', 'stmbda706_02553',
    #  4.1
    'voiceman_04100',
    'stmbdb101_02962', 'stmbdb102_02963', 'stmbdb103_02964', 'stmbdb104_02965',
    'stmbdb105_02966', 'stmbdb106_02967', 'stmbdb107_02968', 'stmbdb108_02969',
    'stmbdb109_02970', 'stmbdb110_02971', 'stmbdb111_02972',
    #  4.2
    'voiceman_04200',
    'stmbdc101_03022', 'stmbdc102_03023', 'stmbdc103_03024', 'stmbdc104_03025',
    'stmbdc105_03026', 'stmbdc106_03027', 'stmbdc107_03028', 'stmbdc108_03029',
    #  4.3
    'voiceman_04300',
    'stmbdd101_03070', 'stmbdd102_03071', 'stmbdd103_03072', 'stmbdd104_03073',
    'stmbdd105_03074', 'stmbdd106_03075', 'stmbdd107_03076',
    #  4.4
    'voiceman_04400',
    'stmbde101_03143', 'stmbde102_03144', 'stmbde103_03145', 'stmbde104_03146',
    'stmbde105_03147', 'stmbde106_03148', 'stmbde107_03149',
    'voiceman_04401',
    #  4.5
    'voiceman_04500',
    'stmbdf101_03179', 'stmbdf102_03180', 'stmbdf103_03181', 'stmbdf104_03182',
    'stmbdf105_03183',
    #  4.58
    'voiceman_04505',
    'stmbdg101_03184', 'stmbdg102_03185',
    # 5.0 - Shadowbringers
    'voiceman_05000',
    'luckma101_03279', 'luckma102_03280', 'luckma103_03281', 'luckma201_03282',
    'luckma202_03283', 'luckma203_03284', 'luckma204_03285', 'luckma205_03286',
    'luckma206_03287', 'luckma207_03288', 'luckma208_03289', 'luckma209_03290',
    'luckma301_03291', 'luckma302_03292', 'luckma303_03293', 'luckma304_03294',
    'luckma305_03295', 'luckma306_03296', 'luckma307_03297', 'luckma308_03298',
    'luckma309_03299', 'luckma401_03300', 'luckma402_03301',
    'voiceman_05001',
    'luckmb101_03302', 'luckmb102_03303', 'luckmb103_03304', 'luckmb104_03305',
    'luckmb105_03306', 'luckmb106_03307', 'luckmb107_03308', 'luckmb108_03309',
    'luckmb109_03310', 'luckmb110_03311', 'luckmb111_03312', 'luckmb112_03313',
    'luckmb113_03314', 'luckmb114_03315', 'luckmb115_03316', 'luckmb116_03317',
    'luckmb117_03318', 'luckmb118_03319', 'luckmb119_03320', 'luckmb120_03321',
    'voiceman_05002',
    'luckmc101_03322', 'luckmc102_03323', 'luckmc103_03324', 'luckmc104_03325',
    'luckmc105_03326', 'luckmc106_03327', 'luckmc107_03328', 'luckmc108_03329',
    'luckmc109_03330', 'luckmc110_03331', 'luckmc111_03332', 'luckmc112_03333',
    'luckmc113_03334', 'luckmc114_03335', 'luckmc115_03336', 'luckmc116_03337',
    'luckmc117_03338', 'luckmc118_03339', 'luckmc119_03340', 'luckmc120_03341',
    'luckmc121_03342',
    'voiceman_05003',
    'luckmd101_03606', 'luckmd102_03607', 'luckmd103_03608', 'luckmd104_03609',
    'luckmd105_03610', 'luckmd106_03611', 'luckmd107_03612', 'luckmd108_03613',
    'luckmd109_03614', 'luckmd110_03615', 'luckmd111_03616', 'luckmd112_03617',
    'luckmd113_03618', 'luckmd114_03619', 'luckmd115_03620', 'luckmd116_03621',
    'luckmd117_03622',
    'voiceman_05004',
    'luckme101_03630', 'luckme102_03631', 'luckme103_03632', 'luckme104_03633',
    'luckme105_03634', 'luckme106_03635', 'luckme107_03636', 'luckme108_03637',
    'luckme109_03638', 'luckme110_03639', 'luckme111_03640', 'luckme112_03641',
    'luckme113_03642', 'luckme114_03643', 'luckmf101_03644',
    'voiceman_05005',
    'luckmf102_03645', 'luckmf103_03646', 'luckmf104_03647', 'luckmf105_03648',
    'luckmf106_03649', 'luckmf107_03650', 'luckmf108_03651', 'luckmf109_03652',
    'luckmf110_03653', 'luckmf111_03654',
    'voiceman_05006',
    #  5.1
    'voiceman_05100',
    'luckmg101_03673', 'luckmg102_03674', 'luckmg103_03675', 'luckmg104_03676',
    'luckmg105_03677', 'luckmg106_03678', 'luckmg107_03679', 'luckmg108_03680',
    'luckmg109_03681', 'luckmg110_03682',
    #  5.2
    'voiceman_05200',
    'luckmh101_03761', 'luckmh102_03762', 'luckmh103_03763', 'luckmh104_03764',
    'luckmh105_03765', 'luckmh106_03766', 'luckmh107_03767', 'luckmh108_03768',
    'luckmh109_03769', 'luckmh110_03770',
    #  5.3
    'voiceman_05300',
    'luckmi101_03771', 'luckmi102_03772', 'luckmi103_03773', 'luckmi104_03774',
    'gaiusc605_01005', 'luckmi105_03775', 'luckmi106_03776', 'luckmi107_03777',
    'luckmi108_03778', 'luckmi109_03779', 'luckmi110_03780', 'luckmi111_03781',
    'luckmi112_03782',
    'voiceman_05301',
    #  5.4
    'voiceman_05400',
    'luckmj101_04007', 'luckmj102_04008', 'luckmj103_04009', 'luckmj104_04010',
    'luckmj105_04011', 'luckmj106_04012', 'luckmj107_04013', 'luckmj108_04014',
    'luckmj109_04015', 'luckmj110_04016',
    #  5.5
    #   Part 1
    'voiceman_05500',
    'luckmk101_04058', 'luckmk102_04059', 'luckmk103_04060', 'luckmk104_04061',
    'luckmk105_04062', 'luckmk106_04063',
    #   Part 2
    'voiceman_05505',
    'luckml101_04064', 'luckml102_04065', 'luckml103_04066',
    # 6.0 - Endwalker
    'voiceman_06000',
    'aktkma101_04357', 'aktkma102_04358',
    'aktkma103_04359', 'aktkma104_04360', 'aktkma105_04361', 'aktkma106_04362',
    'aktkma107_04363', 'aktkma108_04364', 'aktkma109_04365', 'aktkma110_04366',
    'aktkma111_04367',
    'aktkma112_04368', 'aktkma113_04369', 'aktkma114_04370', 'aktkma115_04371',
    'aktkma116_04372', 'aktkma117_04373', 'aktkma118_04374', 'aktkma119_04375',
    'aktkma120_04376',
    'aktkma121_04377', 'aktkma122_04378', 'aktkma123_04379',
    'voiceman_06001',
    'aktkmb101_04380', 'aktkmb102_04381', 'aktkmb103_04382', 'aktkmb104_04383',
    'aktkmb105_04384', 'aktkmb106_04385', 'aktkmb107_04386', 'aktkmb108_04387',
    'aktkmb109_04388', 'aktkmb110_04389', 'aktkmb111_04390', 'aktkmb112_04391',
    'aktkmb113_04392', 'aktkmb114_04393', 'aktkmb115_04394', 'aktkmb116_04395',
    'aktkmb117_04396', 'aktkmb118_04397', 'aktkmb119_04398',
    'voiceman_06002',
    'aktkmc101_04399', 'aktkmc102_04400', 'aktkmc103_04401', 'aktkmc104_04402',
    'aktkmc105_04403', 'aktkmc106_04404', 'aktkmc107_04405', 'aktkmc108_04406',
    'aktkmc109_04407', 'aktkmc110_04408',
    'voiceman_06003',
    'aktkmd101_04409', 'aktkmd102_04410', 'aktkmd103_04411', 'aktkmd104_04412',
    'aktkmd105_04413', 'aktkmd106_04414', 'aktkmd107_04415', 'aktkmd108_04416',
    'aktkmd109_04417', 'aktkmd110_04418', 'aktkme101_04419',
    'voiceman_06004',
    'aktkme102_04420', 'aktkme103_04421', 'aktkme104_04422', 'aktkme105_04423',
    'aktkme106_04424', 'aktkme107_04425', 'aktkme108_04426', 'aktkme109_04427',
    'aktkme110_04428', 'aktkme111_04429', 'aktkme112_04430', 'aktkme113_04431',
    'aktkme114_04432', 'aktkme115_04433', 'aktkme116_04434', 'aktkme117_04435',
    'aktkme118_04436', 'aktkme119_04437', 'aktkme120_04438',
    'voiceman_06005',
    'aktkmf101_04439', 'aktkmf102_04440', 'aktkmf103_04441', 'aktkmf104_04442',
    'aktkmf105_04443', 'aktkmf106_04444', 'aktkmf107_04445', 'aktkmf108_04446',
    'aktkmf109_04447', 'aktkmf110_04448', 'aktkmf111_04449', 'aktkmg101_04450',
    'voiceman_06006',
    'aktkmg102_04451', 'aktkmg103_04452', 'aktkmg104_04453', 'aktkmg105_04454',
    'aktkmg106_04455', 'aktkmg107_04456', 'aktkmg108_04457', 'aktkmg109_04458',
    'aktkmg110_04459', 'aktkmg111_04460', 'aktkmg112_04461', 'aktkmg113_04462',
    'aktkmg114_04463', 'aktkmg115_04464',
    #  6.1
    'voiceman_06100',
    'aktkmh101_04526', 'aktkmh102_04527', 'aktkmh103_04528', 'aktkmh104_04529',
    'aktkmh105_04530', 'aktkmh106_04531', 'aktkmh107_04532', 'aktkmh108_04533',
    'aktkmh109_04534', 'aktkmh110_04535',
    #  6.2
    'voiceman_06200',
    'aktkmi101_04592', 'aktkmi102_04593', 'aktkmi103_04594', 'aktkmi104_04595',
    'aktkmi105_04596', 'aktkmi106_04597', 'aktkmi107_04598', 'aktkmi108_04599',
    'aktkmi109_04600',
    #  6.3
    'voiceman_06300',
    'aktkmj101_04670', 'aktkmj102_04671', 'aktkmj103_04672', 'aktkmj104_04673',
    'aktkmj105_04674', 'aktkmj106_04675', 'aktkmj107_04676', 'aktkmj108_04677',
    'aktkmj109_04678',
    #  6.4
    'voiceman_06400',
    'aktkmk101_04735', 'aktkmk102_04736', 'aktkmk103_04737', 'aktkmk104_04738',
    'aktkmk105_04739', 'aktkmk106_04740', 'aktkmk107_04741', 'aktkmk108_04742',
    'aktkmk109_04743',
    #  6.5
    #   Part 1
    'voiceman_06500',
    'aktkml101_04744', 'aktkml102_04745', 'aktkml103_04746', 'aktkml104_04747',
    'aktkml105_04748', 'aktkml106_04749', 'aktkml107_04750',
    #   Part 2
    'voiceman_06505',
    'aktkmm101_04751', 'aktkmm102_04752', 'aktkmm103_04753',

    # Class/Job quests
    #  - GLD
    'clsgla001_00177', 'clsgla011_00285', 'clsgla020_00253', 'clsgla021_00286',
    'clsgla050_00256', 'clsgla100_00261', 'clsgla101_00288', 'clsgla150_00262',
    'clsgla200_00263', 'clsgla250_00264', 'clsgla300_00265',
    #  - PGL
    'clspgl001_00178', 'clspgl011_00532', 'clspgl020_00533', 'clspgl021_00553',
    'clspgl050_00554', 'clspgl100_00555', 'clspgl101_00698', 'clspgl150_00558',
    'clspgl200_00562', 'clspgl250_00566', 'clspgl300_00567',
    #  - MRD
    'clsexc001_00179', 'clsexc011_00310', 'clsexc020_00311', 'clsexc021_00312',
    'clsexc050_00313', 'clsexc100_00314', 'clsexc101_00315', 'clsexc150_00316',
    'clsexc200_00317', 'clsexc250_00318', 'clsexc300_00319',
    #  - LNC
    'clslnc000_00023', 'clslnc999_00180', 'clslnc998_00132', 'clslnc100_00218',
    'clslnc001_00047', 'clslnc002_00035', 'clslnc997_00143', 'clslnc003_00055',
    'clslnc004_00056', 'clslnc005_00438', 'clslnc006_00439',
    #  - ARC
    'clsarc999_00181', 'clsarc998_00131', 'clsarc000_00021', 'clsarc100_00219',
    'clsarc001_00046', 'clsarc002_00067', 'clsarc997_00134', 'clsarc003_00068',
    'clsarc004_00070', 'clsarc005_00071', 'clsarc006_00076',
    #  - CNJ
    'clscnj000_00022', 'clscnj998_00133', 'clscnj999_00182', 'clscnj100_00211',
    'clscnj001_00048', 'clscnj002_00091', 'clscnj997_00147', 'clscnj003_00092',
    'clscnj004_00093', 'clscnj005_00440', 'clscnj006_00441',
    #  - THM
    'clsthm001_00183', 'clsthm011_00344', 'clsthm020_00345', 'clsthm021_00346',
    'clsthm050_00347', 'clsthm100_00348', 'clsthm101_00349', 'clsthm150_00350',
    'clsthm200_00351', 'clsthm250_00352', 'clsthm300_00353',
    #  - ACN
    'clsacn001_00451', 'clsacn011_00452', 'clsacn020_00453', 'clsacn021_00454',
    'clsacn050_00455', 'clsacn100_00456', 'clsacn101_00457', 'clsacn149_01103',
    'clsacn150_00458', 'clsacn200_00459', 'clsacn250_00460', 'clsacn300_00461',
    #  - ROG
    'clsrog001_00101', 'clsrog011_00102', 'clsrog021_00104', 'clsrog050_00110',
    'clsrog101_00126', 'clsrog150_00144', 'clsrog151_00145', 'clsrog200_00146',
    'clsrog250_00148', 'clsrog300_00154', 'clsrog301_00155',

    #  - PLD
    'jobpld300_01055', 'jobpld350_01056', 'jobpld400_01057',
    'jobpld450_01058', 'jobpld451_01059', 'jobpld500_01060',
    #  - MNK
    'jobmnk300_01061', 'jobmnk350_01062', 'jobmnk400_01063',
    'jobmnk450_01064', 'jobmnk451_01065', 'jobmnk500_01066',
    'jobmnk501_02026', 'jobmnk520_02027', 'jobmnk540_02028',
    'jobmnk560_02029', 'jobmnk580_02030', 'jobmnk600_02031',
    #  - WAR
    'jobwar300_01049', 'jobwar350_01050', 'jobwar400_01051',
    'jobwar450_01052', 'jobwar451_01053', 'jobwar500_01054',
    #  - DRG
    'jobdrg300_01067', 'jobdrg350_01068', 'jobdrg400_01069',
    'jobdrg450_01070', 'jobdrg451_01071', 'jobdrg500_01072',    
    #  - BRD
    'jobbrd300_01085', 'jobbrd350_01086', 'jobbrd400_01087',
    'jobbrd450_01088', 'jobbrd451_01089', 'jobbrd500_01090',
    #  - WHM
    'jobwhm300_01079', 'jobwhm350_01080', 'jobwhm400_01081',
    'jobwhm450_01082', 'jobwhm451_01083', 'jobwhm500_01084',
    #  - DRK
    'jobdrk299_02110', 'jobdrk300_02053', 'jobdrk301_02054', 'jobdrk350_02055',
    'jobdrk400_02056', 'jobdrk450_02057', 'jobdrk500_02058',
    'jobdrk501_02059', 'jobdrk520_02060', 'jobdrk540_02061',
    'jobdrk560_02062', 'jobdrk580_02063', 'jobdrk600_02064',
    'jobdrk601_02915', 'jobdrk630_02916', 'jobdrk650_02917',
    'jobdrk680_02918', 'jobdrk700_02919', 'luckbc012_03221',
    #  - BLM
    'jobblm300_01073', 'jobblm350_01074', 'jobblm400_01075',
    'jobblm450_01076', 'jobblm451_01077', 'jobblm500_01078',
    #  - SMN
    'jobsmn300_01091', 'jobsmn350_01092', 'jobsmn400_01093',
    'jobsmn450_01094', 'jobsmn451_01095', 'jobsmn500_01096',
    #  - SCH
    'jobsch300_01097', 'jobsch350_01098', 'jobsch400_01099',
    'jobsch450_01100', 'jobsch451_01101', 'jobsch500_01102',
    #  - SAM
    'jobsam500_02559', 'jobsam501_02560', 'jobsam520_02561', 'jobsam540_02562',
    'jobsam560_02563', 'jobsam580_02564', 'jobsam600_02565',
    'jobsam601_02566', 'jobsam630_02567', 'jobsam650_02568', 'jobsam680_02569',
    'jobsam700_02570',
    #  - RDM
    'jobrdm500_02576', 'jobrdm501_02577', 'jobrdm520_02578', 'jobrdm540_02579',
    'jobrdm560_02580', 'jobrdm580_02581', 'jobrdm600_02582',
    'jobrdm601_02583', 'jobrdm630_02584', 'jobrdm650_02585', 'jobrdm680_02586',
    'jobrdm700_02587',
    #  - GNB
    'luckbb101_03261', 'luckbb102_03262', 'luckbb111_03263',
    'luckbb121_03264', 'luckbb131_03265', 'luckbb141_03266',
    #  - RPR
    'aktkbb201_04073', 'aktkbb202_04074', 'aktkbb211_04075',
    'aktkbb221_04076', 'aktkbb231_04077', 'aktkbb241_04078',
    #  - BLU
    'jobaoz001_03192', 'jobaoz010_03193', 'jobaoz100_03194', 'jobaoz200_03195',
    'jobaoz300_03196', 'jobaoz400_03197', 'jobaoz500_03198', 'jobaoz501_03199',

    #  - ALC
    'clsalc001_00190', 'clsalc011_00575', 'clsalc021_00577', 'clsalc050_00578',
    'clsalc101_00580', 'clsalc150_00581', 'clsalc200_00582', 'clsalc250_00583',
    'clsalc300_00584', 'clsalc350_00647', 'clsalc400_00648', 'clsalc450_00649',
    'clsalc500_00650',

    # Role quests
    # - Shadowbringers
    #   - Tank
    'luckba101_03243', 'luckba111_03244', 'luckba121_03245',
    'luckba131_03246', 'luckba141_03247', 'luckba151_03248',
    #   - Healer
    #   - Phys. DPS
    'luckba301_03273', 'luckba311_03274', 'luckba321_03275',
    'luckba331_03276', 'luckba341_03277', 'luckba351_03278',
    #   - Mag. DPS
    'luckba401_03623', 'luckba411_03624', 'luckba421_03625',
    'luckba431_03626', 'luckba441_03627', 'luckba451_03628',
    # - Endwalker

    # Primals
    'gaiusd001_01047', 'gaiusd002_01048', 'gaiusd003_01157', 'gaiusd004_01158',
    #'gaiusd011_01194', 'gaiusd012_01195', 'gaiusd013_01196', 'gaiusd014_01197',
    #'gaiusd015_01198', 'gaiusd016_01309', 'gaiusd017_01412', 'gaiusd018_01413',
    #'gaiusd019_01530', 'gaiusd020_00090', 'subcts902_00433',
    # Odin feature quests
    #'gaiusc607_01007', 'gaiusc608_01008', 'gaiusc609_01009', 'gaiusc612_01012',
    # Crystal Tower
    'gaiusd201_01199', 'gaiusx201_01709', 'gaiusd202_01200', 'gaiusd203_01201',
    'gaiusd204_01202', 'gaiusd205_01203', 'gaiusd401_01474', 'gaiusd601_00494',
    'gaiusd602_00495', 'gaiusd701_00497', 'mansea200_00546', 'gaiusd702_00498',
    # The Shadow of Mhach
    'heavnm101_02204', 'heavnm102_02205', 'heavnm201_02285', 'heavnm202_02286',
    'heavnm301_02373', 'heavnm302_02374', 'heavnm303_01480',

    # Dungeon unlock quests
    'gaiusa602_00764', 'gaiusb812_00921', 'gaiusc404_00979', 'gaiusc702_01014',
    'gaiusb501_00870', 'subfst900_01135',

    # Side quests
    'subgsc001_00434', 'gaiusa907_00802', 'subsea921_00699', 'subcts896_03017',
    'subcts897_03018', 'subcts810_01431', 'subcts801_01210',

    # Seasonal Events
    #  - Heavensturn
    #    2023
    'fesnyr901_04588', 'fesnyr902_04589',
    #  - Valentione's Day
    #    2024
    'fesvlx001_04808', 'fesvlx002_04809',
    #    2023
    'fesvlt901_04654',
    #  - Little Ladies' Day
    #    2024
    'fespdy901_04810', 'fespdy902_04811',
    #    2023
    'fespdy801_04720',
    #    2022
    'fespdy701_04471', 'fespdy702_04472',
    #  - Hatching-tide
    #    2023
    'fesest901_04721', 'fesest902_04722',
    #    2022
    'fesest801_04590',
    #  - Make It Rain
    #    2024
    'fesgsc801_04814',
    #    2023
    'fesgsc701_04727', 'fesgsc702_04728',
    #    2022
    'fesgsc601_04584', 
    #  - Moonfire Faire
    #    2023
    'fessum901_04723', 'fessum902_04724',
    #    2022
    'fessum801_04540', 'fessum802_04541',
    #  - The Rising
    #    2023
    'fesanv901_04765', 'fesanv902_04766',
    #    2022
    'fesanv801_04544',
    #  - All Saints' Wake
    #    2023
    'feshlw901_04785', 'feshlw902_04786',
    #    2022
    'feshlw801_04655', 'feshlw802_04656', 'feshlw803_04657',
    #  - Starlight Celebration
    #    2023
    'fesxms901_04781', 'fesxms902_04782', 'fesxms903_04783',
    #    2022
    'fesxms801_04658', 'fesxms802_04659',
    
    #  - FFXVI Collab 2024
    'fessxt101_04796', 'fessxt102_04797', 'fessxt103_04798',
    #  - FFXV Collab 2019
    'fesbkc001_03158', 'fesbkc002_03159', 'fesbkc003_03160',
    #  - FFXI Collab 2015
    'fesevn101_02206',
    #  - Yo-kai Watch
    'fesykw001_02141',

    # Island Sanctuary
    'aktkua101_04643', 'aktkua102_04644', 'aktkua201_04645'
)

# (NOT IMPLEMENTED)
# In what quest files should index be added at the start of the string?
# This was made by request of one of the translators. The quests from this
# list will get a decimal number at the start of the strings which would allow
# translators to go directly to the string with this number in the quest file.
#
# Note: Adding index will remove cache, so that after removing a file from this
#       list it would be converted again.
$global:QUEST_ADD_INDEX_LIST = @(
    
)

# File splitting
#
# Some of the game files (e.g. 'Item', 'Status') have both name and description
# in one file. If you want to keep names and descriptions separated, this
# feature should prove to be useful.
# The syntax is following:
#
#   <original_file_name> = @{
#       <new_file_name_1> = @{
#           Columns = @( <column_1>[,<column_2>[...]] )
#           [Language = <language_1>]
#       }
#       <new_file_name_2> = @{
#           Columns = @( <column_3>[,<column_4>[...]] )
#           [Language = <language_2>]
#       }
#       [...]
#   }
#
# Here, file 'Item' will be split in two files: 'ItemName' and 'ItemTransient'.
# 'ItemName' will have columns 0, 1, and 3, while 'ItemTransient' will only have column 2.
# You can have as many files and columns as you need. If a column is not mentioned in any
# of defined files, it will be dropped. First column number is 0.
#
# You can also specify what strings language to take during conversion to game data.
# If 'Language' is not defined, script language will be taken. Thus, in our example ItemName
# would be from EN file, while ItemTransient would be from the language that was specified
# during the script call.
#
# Strings files for each new file will be put inside original one. In the example above,
# 'Item' folder will have new folders 'ItemName' and 'ItemTransient'. Each of the nested
# folders would have their respective strings files.
#
# Note 1: 'Column number' refers to _string_ column number, not an actual column number
#         in the file.
# Note 2: This won't split existing full strings files. You'll have to do it yourself
#         or redo a conversion from EXD.
# Note 3. The feature works only in ConvertFrom-GameData and ConvertAllStringsToGameData
#         (splitting/combining). This feature DOES NOT work in ConvertTo-GameData.
$global:SPLIT_FILE_LIST = @{
    Item = @{
        ItemName = @{
            Columns = @( 0, 1, 3 )
            Language = 'en'
        } 
        ItemTransient = @{
            Columns = @( 2 )
        }
    }
}
