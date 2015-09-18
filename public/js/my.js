function readURL(input) {
        if (input.files && input.files[0]) {
            var reader = new FileReader();

            reader.onload = function (e) {
                $('#top-image').css('background', 'url('+e.target.result +')');
                $.post('/notes', {data: e.target.result, name: "image"}, function(data) {
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
                        if (note[3] == true) {
                            for (var i = 0; i < note[0].length; ++i) {
										  timing = .25*note[0].length*Math.random();
                                MIDI.noteOn(0, note[0][i], 127*(4-note[1])/4.0, delay + timing);
                                MIDI.noteOff(0, note[0][i], delay + 0.6/note[0].length + timing);                            
                                delay += .25/note[0].length;
                            }
                        } else {
                            MIDI.chordOn(0, note[0], 64*(4-note[1])/4.0, delay + note[2]*.25);
                            MIDI.chordOff(0, note[0], delay + 0.6 + note[2]*.25);                            
                            delay += .25;
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
