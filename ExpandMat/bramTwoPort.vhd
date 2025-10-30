library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;
use work.GlobalVars.all;

entity bramTwoPort is
  generic (
    width   : integer := 32;
    depth   : integer := 8
  );

  	PORT
	(
    clk		      : IN STD_LOGIC;
		address_a		: IN STD_LOGIC_VECTOR (depth - 1 DOWNTO 0);
		address_b		: IN STD_LOGIC_VECTOR (depth - 1 DOWNTO 0);
		data_a		  : IN STD_LOGIC_VECTOR (width - 1 DOWNTO 0);
		data_b		  : IN STD_LOGIC_VECTOR (width - 1 DOWNTO 0);
		wren_a		  : IN STD_LOGIC  := '0';
		wren_b		  : IN STD_LOGIC  := '0';
		q_a		      : OUT STD_LOGIC_VECTOR (width - 1 DOWNTO 0);
		q_b		      : OUT STD_LOGIC_VECTOR (width - 1 DOWNTO 0)
	);

  attribute RAM_STYLE         : string;
  attribute RAM_STYLE of bramTwoPort : entity is "block";
end entity;

architecture RTL of bramTwoPort is
  subtype word_t is std_logic_vector(width - 1 downto 0);
  type memory_t is array(0 to 2**depth-1) of word_t;

  --shared variable ram : memory_t := (others => (others => '0'));
  shared variable ram : memory_t := (
    0 => x"62C5FE44",
    1 => x"29752F83",
    2 => x"3060AD65",
    3 => x"A55F85B8",
    4 => x"B61F2ED4",
    5 => x"6A939E47",
    6 => x"883A11E8",
    7 => x"CD2E79B4",
    8 => x"F98121D5",
    9 => x"B44C61E3",
    10 => x"CFEBEC50",
    11 => x"5DACA342",
    12 => x"B2A56628",
    13 => x"20F51704",
    14 => x"9674109D",
    15 => x"774633E8",
    16 => x"2EE1F32B",
    17 => x"4EC0F4B4",
    18 => x"7B35A68D",
    19 => x"5EE4337D",
    20 => x"E27339BD",
    21 => x"10E421D7",
    22 => x"A6A87F14",
    23 => x"1AC279C8",
    24 => x"62338AE5",
    25 => x"425363EB",
    26 => x"87B67A83",
    27 => x"0D72FD8E",
    28 => x"6D077655",
    29 => x"74807931",
    30 => x"BEE9BC65",
    31 => x"7FD916CF",
    32 => x"DB685FF5",
    33 => x"BCECDA63",
    34 => x"6D03A6F4",
    35 => x"C8DCC625",
    36 => x"C306C4DF",
    37 => x"9021E980",
    38 => x"A68F1020",
    39 => x"664648A5",
    40 => x"019914A7",
    41 => x"B5C9016C",
    42 => x"FA3F60A5",
    43 => x"28AA18A7",
    44 => x"4EE2725A",
    45 => x"FCA66AE3",
    46 => x"E1CFED5E",
    47 => x"0A501705",
    48 => x"D8D3B321",
    49 => x"1E96DFEC",
    50 => x"460381E8",
    51 => x"87ADA522",
    52 => x"73F1E8E8",
    53 => x"BEF9E5F9",
    54 => x"4F1888C5",
    55 => x"7ED7F894",
    56 => x"9C4E7FA4",
    57 => x"33E232D5",
    58 => x"2FC0369A",
    59 => x"BFD483D9",
    60 => x"E65CA7C9",
    61 => x"E989AFD2",
    62 => x"313FC711",
    63 => x"FA13E708",
    64 => x"86283707",
    65 => x"BF6AFBD9",
    66 => x"827A89DC",
    67 => x"AE3037B1",
    68 => x"B6C670BE",
    69 => x"3DDAF119",
    70 => x"BD606307",
    71 => x"461E3B59",
    72 => x"7DBAEB67",
    73 => x"3C6521B7",
    74 => x"F0C8FE1B",
    75 => x"EE1DB50A",
    76 => x"F3ABB659",
    77 => x"FD1DE9BD",
    78 => x"E5E8C8C4",
    79 => x"9F47848B",
    80 => x"5BF8F3A1",
    81 => x"34FA63BD",
    82 => x"4AF5AAD4",
    83 => x"BE8A15B1",
    84 => x"91C7C9FA",
    85 => x"2BE98681",
    86 => x"C3653B5D",
    87 => x"10B50DBB",
    88 => x"E917A7D6",
    89 => x"17BAED89",
    90 => x"8FFFC96C",
    91 => x"FC535CB2",
    92 => x"4FC90183",
    93 => x"7C6FC1DC",
    94 => x"68E555EB",
    95 => x"F82366F6",
    96 => x"F90412CB",
    97 => x"2B10B97C",
    98 => x"791E77B2",
    99 => x"3B74FB05",
    100 => x"6D8222CB",
    101 => x"A673766F",
    102 => x"79DD7D73",
    103 => x"7C0BD1E1",
    104 => x"D011392A",
    105 => x"DB5FD44F",
    106 => x"279A11DF",
    107 => x"10DF7E80",
    108 => x"CCF261A6",
    109 => x"835FFF00",
    110 => x"7426D2F8",
    111 => x"25A57FE5",
    112 => x"F2C7951A",
    113 => x"D1C17EB2",
    114 => x"7F5D1A98",
    115 => x"346E45B0",
    116 => x"75AA8F24",
    117 => x"9F969CC6",
    118 => x"3497D909",
    119 => x"47F095DE",
    120 => x"851651A2",
    121 => x"284CA4C1",
    122 => x"89CDA981",
    123 => x"FB04800B",
    124 => x"5E85F4BC",
    125 => x"3A424436",
    126 => x"B2E9725F",
    127 => x"7E8D661A",
    128 => x"E1348A5B",
    129 => x"FCDAA1D5",
    130 => x"72C1EB77",
    131 => x"72FA7EFB",
    132 => x"67CB2B74",
    133 => x"0223FCA2",
    134 => x"77E4B12D",
    135 => x"490C3702",
    136 => x"1A9A962E",
    137 => x"BEC7932B",
    138 => x"90D8B2CC",
    139 => x"8DEE459B",
    140 => x"9358CCEF",
    141 => x"7F090977",
    142 => x"05844510",
    143 => x"ED824748",
    144 => x"C24580D2",
    145 => x"C6E2FE93",
    146 => x"09469796",
    147 => x"63E37123",
    148 => x"DD5EDC06",
    149 => x"AA5DF565",
    150 => x"52903204",
    151 => x"BC61E496",
    152 => x"6225D243",
    153 => x"453242B8",
    154 => x"F6DBFFA1",
    155 => x"60912600",
    156 => x"834405DA",
    157 => x"76EE7DA1",
    158 => x"668E8BAB",
    159 => x"D51448E3",
    160 => x"4699BFAE",
    161 => x"E68281C3",
    162 => x"49EDFC57",
    163 => x"4EFE25B8",
    164 => x"813AB9E8",
    165 => x"BB15C9B1",
    166 => x"8A1E1B5C",
    167 => x"3C0338C1",
    168 => x"5B20B877",
    169 => x"D951F715",
    170 => x"40A03664",
    171 => x"911CD3B5",
    172 => x"B9215C9F",
    173 => x"5F7C1AA3",
    174 => x"1B9D1EC9",
    175 => x"4D9FF0BE",
    176 => x"870F9764",
    177 => x"6AAB03E2",
    178 => x"A225DFA2",
    179 => x"D99A5C8A",
    180 => x"65278B23",
    181 => x"77377572",
    182 => x"35B9D5C2",
    183 => x"63B98338",
    184 => x"41F7F59C",
    185 => x"9A186586",
    186 => x"4F6CF078",
    187 => x"528C46D2",
    188 => x"27F57379",
    189 => x"FDCC3CA6",
    190 => x"E61B1609",
    191 => x"F9190ACA",
    192 => x"CB9987AB",
    193 => x"3722B431",
    194 => x"686E9066",
    195 => x"82CBFC2D",
    196 => x"3F77DFE0",
    197 => x"63109C1B",
    198 => x"788BD4DA",
    199 => x"16EC1D0D",
    200 => x"7C14B345",
    201 => x"96930F9F",
    202 => x"37E356D4",
    203 => x"D8CD792A",
    204 => x"306B48FB",
    205 => x"DA29F99E",
    206 => x"5132E2FB",
    207 => x"2DA30811",
    208 => x"89FC3D1B",
    209 => x"3D46C024",
    others => (others => '0'));


begin

  

  sequential1 : process(clk)
  begin
    if (clk'event and clk = '1') then
      --Write Logic
      if(wren_a = '1') then
        ram(to_integer(unsigned(address_a))) := data_a;
      end if;
      --Read Logic
      q_a <= ram(to_integer(unsigned(address_a)));
    end if;
  end process;


  sequential2 : process(clk)
  begin
    if (clk'event and clk = '1') then
      --Write Logic
      if(wren_b = '1') then
        ram(to_integer(unsigned(address_b))) := data_b;
      end if;
      --Read Logic
      q_b <= ram(to_integer(unsigned(address_b)));
    end if;
  end process;


end RTL;