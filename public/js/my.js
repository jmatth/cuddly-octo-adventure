function readURL(input) {
        if (input.files && input.files[0]) {
            var reader = new FileReader();

            reader.onload = function (e) {
                $('#top-image').css('background', 'url('+e.target.result +')');
                $.get('/notes', function(data) {
                    var delay = 0
                    var pos = 0
                    xx = function() {
                        if (pos >= data["notes"].length) {
                            clearInterval(xx);
                            return;
                        }
                        note = data["notes"][pos++];
                        window.console&&console.log("Playing " + pos);
                        // MIDI.setVolume(0, 127);
                        if (Math.random() > 0.5) {
                            for (var i = 0; i < note[0].length; ++i) {
                                MIDI.noteOn(0, note[0][i], 127, delay + notes[2]*.25);
                                MIDI.noteOff(0, note[0][i], delay + 0.1 + notes[2]*.25);                            
                                delay += .1;
                            }
                        } else {
                            MIDI.chordOn(0, note[0], 127, delay + notes[2]*.25);
                            MIDI.chordOff(0, note[0], delay + 0.4 + notes[2]*.25);                            
                            delay += .25;
                        }
                        
                    }
                        // MIDI.chordOff(0, note[0], 127, delay);
                    };
                    window.console&&console.log(data);
                    setInterval(xx, 250);
                }); 
            };

            reader.readAsDataURL(input.files[0]);
        }
    }