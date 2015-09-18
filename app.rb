require 'sinatra'
require 'sinatra/json'
require 'json'
require 'opencv'


include OpenCV
NOTES = {
  "C"  => 0,
  "Cs" => 1,
  "Db" => 1,
  "D"  => 2,
  "Ds" => 3,
  "Eb" => 3,
  "E"  => 4,
  "Es" => 5,
  "F"  => 5,
  "Fs" => 6,
  "Gb" => 6,
  "G"  => 7,
  "Gs" => 8,
  "Ab" => 8,
  "A"  => 9,
  "As" => 10,
  "Bb" => 10,
  "B"  => 11,
  "Bs" => 0
}

CHORDS = {
  "aM" => %w{A Cs E},
  "bM" => %w{B Ds Fs},
  "cM" => %w{C E G},
  "dM" => %w{D Fs A},
  "eM" => %w{E Gs B},
  "fM" => %w{F A C},
  "gM" => %w{G B D},

  "am" => %w{A C E},
  "bm" => %w{B D Fs},
  "cm" => %w{C Eb G},
  "dm" => %w{D F A},
  "em" => %w{E G B},
  "fm" => %w{F Ab C},
  "gm" => %w{G Bb D},

  "csm" => %w{Cs E Gs},
  "dsm" => %w{Ds Fs As},
  "fsm" => %w{Fs A Cs},
  "gsm" => %w{Gs B Ds},

  "bfM" => %w{Bn D F},
  "fsM" => %w{Fs As Cs},
}


KEYS = [
  %w{aM bm csm dM eM fsm},   #a
  %w{bM csm dsm eM fsM gsm}, #b
  %w{cM dm em fM gM am},     #c
  %w{dM em fsm gM aM bM},    #d
  %w{eM fsm gsm aM bM csm},  #e
  %w{fM gm am bfM cM dm},    #f
  %w{gM am bm cM dM em},     #g
]
KEYNAMES = %w{ A B C D E F G }

get '/notes' do
  @img = CvMat.load('./lena-32x32.jpg')
  avg = @img.avg
  b, g, r = avg[0].to_i, avg[1].to_i, avg[2].to_i
  key = (b+g+r) % KEYS.count
  keyname = KEYNAMES[key]
  chording = KEYS[key]

  response = []
  rows, cols = @img.dims
  rows.times do |row|
    cols.times do |col|
      color = @img[row,col]
      b,g,r = color[0].to_i, color[1].to_i, color[2].to_i

      val = b + g + r

      # Max 10 bits of info.
      del = (val & 0b1110000000) >> 7
      chd = (val & 0b0001110000) >> 4
      exc = (val & 0b0000001100) >> 2
      vol = (val & 0b0000000011)

      chd = rand(0..5) if chd > 5 # To avoid bias, randomize instead of mod


      octave = 0
      chord = CHORDS[chording[chd]]
      bit = []
      exc.times do
        bit += chord.map {|x| NOTES[x] + octave}
        octave += 12
      end
      response << [bit, vol, del]
    end
  end
  content_type :json
  json key: keyname, notes: response
end

