class BeatmapEditor {
    constructor() {
        this.audio = new Audio();
        this.notes = [];
        this.isPlaying = false;
        this.currentTime = 0;
        
        this.setupEventListeners();
        this.updateTimeline();
    }

    setupEventListeners() {
        // Prevent arrow key scrolling
        window.addEventListener('keydown', (e) => {
            if(['ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight', ' '].includes(e.key)) {
                e.preventDefault();
            }
        });

        // Audio file input
        document.getElementById('audioFile').addEventListener('change', (e) => this.loadAudio(e));

        // Playback controls
        document.getElementById('playPause').addEventListener('click', () => this.togglePlayback());
        document.getElementById('stop').addEventListener('click', () => this.stopPlayback());
        document.getElementById('save').addEventListener('click', () => this.saveBeatmap());

        // Keyboard controls
        document.addEventListener('keydown', (e) => {
            if (e.repeat) return;
            
            switch(e.key) {
                case 'ArrowLeft':
                    this.addNote('left');
                    break;
                case 'ArrowDown':
                    this.addNote('down');
                    break;
                case 'ArrowUp':
                    this.addNote('up');
                    break;
                case 'ArrowRight':
                    this.addNote('right');
                    break;
                case ' ':
                    this.togglePlayback();
                    break;
            }
        });

        // Audio time update
        this.audio.addEventListener('timeupdate', () => {
            this.currentTime = this.audio.currentTime;
            this.updateStatus();
            this.highlightCurrentNotes();
            this.scrollToCurrentTime();
        });
    }

    loadAudio(event) {
        const file = event.target.files[0];
        if (!file) return;

        const url = URL.createObjectURL(file);
        this.audio.src = url;
        this.songName = file.name.replace('.mp3', '');
        this.setStatus(`Loaded: ${this.songName}`);
    }

    togglePlayback() {
        if (this.isPlaying) {
            this.audio.pause();
            this.setStatus('Paused');
        } else {
            this.audio.play();
            this.setStatus('Playing');
        }
        this.isPlaying = !this.isPlaying;
    }

    stopPlayback() {
        this.audio.pause();
        this.audio.currentTime = 0;
        this.isPlaying = false;
        this.setStatus('Stopped');
        this.highlightCurrentNotes();
        this.scrollToCurrentTime();
    }

    addNote(direction) {
        if (!this.audio.duration) {
            this.setStatus('Please load an audio file first');
            return;
        }

        const note = {
            time: this.currentTime,
            direction: direction
        };

        this.notes.push(note);
        this.notes.sort((a, b) => a.time - b.time);
        this.updateTimeline();
        this.setStatus(`Added ${direction} arrow at ${this.formatTime(this.currentTime)}`);
        this.scrollToCurrentTime();
    }

    updateTimeline() {
        const timeline = document.getElementById('timeline');
        timeline.innerHTML = '';

        if (this.notes.length === 0) {
            timeline.innerHTML = '<div class="empty-message">No notes yet. Use arrow keys to add notes.</div>';
            return;
        }

        // Create a list container
        const list = document.createElement('div');
        list.className = 'note-list';

        // Add notes
        this.notes.forEach((note, index) => {
            const noteElement = document.createElement('div');
            noteElement.className = 'note';
            noteElement.dataset.time = note.time;
            noteElement.innerHTML = `
                <span class="note-time">${this.formatTime(note.time)}</span>
                <span class="note-direction">${note.direction.toUpperCase()}</span>
                <span class="note-delete">×</span>
            `;

            noteElement.querySelector('.note-delete').addEventListener('click', () => {
                this.notes.splice(index, 1);
                this.updateTimeline();
                this.setStatus('Note deleted');
            });

            list.appendChild(noteElement);
        });

        timeline.appendChild(list);
    }

    scrollToCurrentTime() {
        if (!this.isPlaying) return;

        const timeline = document.getElementById('timeline');
        const notes = timeline.querySelectorAll('.note');
        let targetNote = null;

        // Find the first note that's after the current time
        for (const note of notes) {
            const noteTime = parseFloat(note.dataset.time);
            if (noteTime >= this.currentTime) {
                targetNote = note;
                break;
            }
        }

        if (targetNote) {
            const timelineRect = timeline.getBoundingClientRect();
            const noteRect = targetNote.getBoundingClientRect();
            
            // Calculate scroll position to keep current note in the middle
            const scrollTarget = noteRect.top - timelineRect.top - (timelineRect.height / 2) + timeline.scrollTop;
            
            timeline.scrollTo({
                top: scrollTarget,
                behavior: 'smooth'
            });
        }
    }

    highlightCurrentNotes() {
        const notes = document.querySelectorAll('.note');
        notes.forEach(noteElement => {
            noteElement.classList.remove('selected');
            noteElement.classList.remove('current');
        });

        if (!this.isPlaying) return;

        const currentTime = this.currentTime;
        notes.forEach(noteElement => {
            const noteTime = parseFloat(noteElement.dataset.time);
            if (Math.abs(noteTime - currentTime) < 0.1) {
                noteElement.classList.add('selected');
                noteElement.classList.add('current');
            }
        });
    }

    formatTime(seconds) {
        const mins = Math.floor(seconds / 60);
        const secs = Math.floor(seconds % 60);
        const ms = Math.floor((seconds % 1) * 1000);
        return `${mins}:${secs.toString().padStart(2, '0')}.${ms.toString().padStart(3, '0')}`;
    }

    setStatus(message) {
        document.getElementById('status').textContent = message;
    }

    saveBeatmap() {
        if (this.notes.length === 0) {
            this.setStatus('No notes to save!');
            return;
        }

        // Create Lua table string with proper formatting
        let luaContent = 'return {\n';
        luaContent += `    name = "${this.songName}",\n`;
        luaContent += `    audio = "assets/${this.songName}.mp3",\n`;
        luaContent += '    difficulty = "Custom",\n';
        luaContent += '    bpm = 120,\n';
        luaContent += '    arrows = {\n';

        // Group notes by 8-second sections
        const sectionSize = 8;
        let currentSection = 0;
        let patternDescription = '';

        this.notes.forEach((note, index) => {
            // Add section comment if entering new section
            const noteSection = Math.floor(note.time / sectionSize);
            if (noteSection > currentSection) {
                currentSection = noteSection;
                const sectionStart = currentSection * sectionSize;
                const sectionEnd = sectionStart + sectionSize;
                
                // Determine pattern description based on note density
                const notesInSection = this.notes.filter(n => 
                    n.time >= sectionStart && n.time < sectionEnd
                ).length;
                
                if (notesInSection > 12) patternDescription = "Intense Pattern";
                else if (notesInSection > 8) patternDescription = "Complex Sequence";
                else if (notesInSection > 4) patternDescription = "Basic Pattern";
                else patternDescription = "Simple Sequence";

                luaContent += '\n';
                luaContent += `        -- ${sectionStart}-${sectionEnd} seconds\n`;
                luaContent += `        -- ${patternDescription}\n`;
            }

            // Format each note with proper indentation and spacing
            luaContent += '        {';
            luaContent += `time = ${note.time.toFixed(2)}, `;
            luaContent += `direction = "${note.direction}"`;
            luaContent += `}${index < this.notes.length - 1 ? ',' : ''}\n`;
        });

        luaContent += '    }\n}';

        // Create and download file
        const blob = new Blob([luaContent], { type: 'text/plain' });
        const url = URL.createObjectURL(blob);
        
        const a = document.createElement('a');
        a.href = url;
        a.download = `pattern.lua`;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
        
        this.setStatus('Beatmap saved!');
    }
}

// Initialize editor when page loads
window.addEventListener('load', () => {
    window.editor = new BeatmapEditor();
});