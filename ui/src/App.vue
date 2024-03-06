<script>
    import NUI from './components/NUI.vue';
    export default {
        data() {
            return {
                type: String,
                ShowMiniGame: false,
                Rows: [],
                CorrectLetters: [],
                GameData: [],
                TimerWidth: '100%',
                TimerInterval: null,
                GameOutcome: '',
            };
        },
        methods: {
            GenerateRandomLetter() {
                const randomCharCode = Math.floor(Math.random() * 26) + 65;
                return String.fromCharCode(randomCharCode);
            },
            GenerateRandomChar() {
                const characters = "abcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+";
                return characters.charAt(Math.floor(Math.random() * characters.length));
            },
            InitializeRows() {
                this.Rows = [];
                this.CorrectLetters = [];
                for (let i = 0; i < 3; i++) {
                    const row = [];
                    const correctRow = [];
                    for (let j = 0; j < 6; j++) {
                        const letter = this.GameData.type === "alphabet" ? this.GenerateRandomLetter() : this.GenerateRandomChar();
                        row.push(letter);
                        correctRow.push(false);
                    }
                    this.Rows.push(row);
                    this.CorrectLetters.push(correctRow);
                }
            },
            HandleKeyPress(event, rowIndex, colIndex) {
                const keyPressed = event.key.toLowerCase();
                const targetChar = this.Rows[rowIndex][colIndex].toLowerCase();

                if (keyPressed === targetChar) {
                    this.PlayAudio();
                    this.CorrectLetters[rowIndex][colIndex] = true;
                    let allCorrect = true;

                    for (let i = 0; i < this.Rows.length; i++) {
                        for (let j = 0; j < this.Rows[i].length; j++) {
                            if (!this.CorrectLetters[i][j]) {
                                allCorrect = false;
                                break;
                            }
                        }
                        if (!allCorrect) {
                            break;
                        }
                    }

                    if (allCorrect) {
                        this.CloseMiniGame(true);
                    }
                } else {
                    this.CorrectLetters[rowIndex][colIndex] = false;
                    const letterElement = document.querySelector(`.row:nth-child(${rowIndex + 1}) .letter:nth-child(${colIndex + 1})`);
                    if (letterElement) {
                        letterElement.classList.add('incorrect');
                        this.CloseMiniGame(false);
                    }
                }
            },
            StartTimer() {
                let startTime = Date.now();
                this.TimerInterval = setInterval(() => {
                    let currentTime = Date.now();
                    let elapsedTime = currentTime - startTime;
                    let remainingTime = this.GameData.time - elapsedTime;
                    let widthPercentage = (remainingTime / this.GameData.time) * 100;

                    if (remainingTime <= 0) {
                        clearInterval(this.TimerInterval);
                        this.CloseMiniGame(false);
                    } else {
                        this.TimerWidth = widthPercentage + '%';
                    }
                }, 100);
            },
            CloseMiniGame(bool) {
                clearInterval(this.TimerInterval);
                this.TimerWidth = '100%';
                this.GameOutcome = bool ? 'passed' : 'failed';

                setTimeout(() => {
                    this.GameOutcome = '';
                    this.ShowMiniGame = false;
                    NUI.methods.NUICallback('outcome', bool);
                }, 2000);
            },
            PlayAudio() {
                const audio = new Audio('https://cfx-nui-sequence-minigame/ui/src/assets/click.mp3');
                audio.play();
            },
        },
        mounted() {
            this.listener = window.addEventListener('message', (event) => {
                switch (event.data.action) {
                    case 'keysequence':
                        this.GameData = event.data;
                        this.ShowMiniGame = true;
                        this.InitializeRows();
                        this.StartTimer();
                        break;
                }
            });

            this.listener = window.addEventListener('keydown', (event) => {
                const validKeys = /^[a-zA-Z0-9!"#$%&'()*+,-./:;<=>?@[\]^_`{|}~]$/;
                if (validKeys.test(event.key)) {
                    for (let rowIndex = 0; rowIndex < this.Rows.length; rowIndex++) {
                        for (let colIndex = 0; colIndex < this.Rows[rowIndex].length; colIndex++) {
                            if (!this.CorrectLetters[rowIndex][colIndex]) {
                                this.HandleKeyPress(event, rowIndex, colIndex);
                                return;
                            }
                        }
                    }
                }

                if (event.key === 'Escape') {
                    this.CloseMiniGame(false);
                }
            });
        },
    };
</script>

<template>
    <div class='container' v-if='ShowMiniGame'>

        <div class='header'>
            <i class='fas fa-gamepad'></i>
            <h1>sequencer</h1>
            <p>press the keys in order</p>
        </div>
  
        <div class='wrapper'>
            
            <div class='letters-container'>
                <div class='row' v-for='(row, rowIndex) in Rows' :key='rowIndex'>
                    <div class='letter' v-for='(letter, colIndex) in row' :key='colIndex' :class='{ correct: CorrectLetters[rowIndex][colIndex] }' >
                    {{ letter }}
                    </div>
                </div>
            </div>
    
            <div class='timer-container' v-if="GameOutcome === ''">
                <div class='timer' :style='{ width: TimerWidth }'></div>
            </div>
            
            <div class="outcome" v-if="GameOutcome !== ''" :class="GameOutcome">
                <p>{{ GameOutcome }}</p>
            </div>
        </div>
    </div>
</template>


<style>

    .container {
        width: auto;
        height: fit-content;
        border-radius: 8px;
        margin: 0;
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        background: #0f0c29b0;
        background: -webkit-linear-gradient(to right, #24243e, #302b63d8, #0f0c29b0);
        background: linear-gradient(to right, #24243e, #302b63d8, #0f0c29b0);
        overflow: hidden;
    }

    .header {
        width: 100%;
        height: 30px;
        padding: 5px;
        display: flex;
        flex-direction: row;
        align-items: center;
        gap: 10px;
    }

    .header i {
        font-size: 20px;
    }

    .header h1 {
        text-transform: capitalize;
        font-size: 20px;
        font-family: 'Bebas Neue', sans-serif;
        font-weight: 400;
        font-style: normal;
        margin: 0;
    }

    .header i, .header h1 {
        color: #ff686b;
        text-shadow: 0px 0px 19px #ff686b49;
    }

    .header h1, .header p {
        text-transform: capitalize;
        font-size: 20px;
        font-family: 'Bebas Neue', sans-serif;
        font-weight: 400;
    }

    .header p {
        color: beige;
        font-size: 12px;
        margin: 0;
    }

    .wrapper {
        padding: 5px;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
    }

    .letters-container {
        width: fit-content;
        height: fit-content;
        padding: 5px;
        height: fit-content;
        display: flex;
        flex-direction: column;
        align-items: center;
        border: 1px solid rgba(255, 255, 255, 0.082);
        border-radius: 8px 8px 0px 0px;
        background: #0f0c29be;
        background: -webkit-linear-gradient(to right, #24243e, #302b63d8, #0f0c29be);
        background: linear-gradient(to right, #24243e, #302b63d8, #0f0c29be);
    }

    .row {
        display: flex;
        flex-direction: row;
        justify-content: center;
        gap: 10px;
        margin: 5px 0;
        width: 100%;

    }

    .letter {
        width: 90px;
        height: 90px;
        display: flex;
        justify-content: center;
        align-items: center;
        font-size: 30px;
        font-family: 'Bebas Neue', sans-serif;
        font-weight: 400;
        font-style: normal;
        color: white;
        background-color: #0f0c2980;
        border-radius: 8px;
        border: 1px solid rgba(255, 255, 255, 0.116);
    }

    .timer-container {
        width: 100%;
        height: 10px;
        display: flex;
        justify-content: center;
        align-items: center;
        margin-top: 5px;
        border-radius: 0px 0px 8px 8px;
        background-color: #0a263950;
        overflow: hidden;
    }
    
    .timer p {
        font-family: 'Bebas Neue', sans-serif;
        font-weight: 400;
        font-style: normal;
        color: white;
        font-size: 12px;
        margin: 0;
        position: absolute;
        right: 0;
        bottom: 0;
        padding: 5px;
    }
    
    .letter.correct {
        color: #24243e;
        background-color: #9f9fed !important;
        box-shadow: 0px 0px 30px 0px rgba(0,0,0,0.87) inset;
        -webkit-box-shadow: 0px 0px 30px 0px rgba(0, 0, 0, 0.87) inset;
        -moz-box-shadow: 0px 0px 30px 0px rgba(0, 0, 0, 0.87) inset;
    }

    .letter.incorrect {
        color: #24243e;
        background-color: #ff686b88 !important;
        box-shadow: 0px 0px 27px 0px rgba(0,0,0,0.79) inset;
        -webkit-box-shadow: 0px 0px 27px 0px rgba(0,0,0,0.79) inset;
        -moz-box-shadow: 0px 0px 27px 0px rgba(0,0,0,0.79) inset;
    }

    .timer {
        width: 100%;
        height: 100%;
        background-color: #ff686b;
        transition: width 0.1s linear;
        box-shadow: 0px 0px 10px 0px rgba(0,0,0,0.79) inset;
        -webkit-box-shadow: 0px 0px 10px 0px rgba(0,0,0,0.79) inset;
        -moz-box-shadow: 0px 0px 10px 0px rgba(0,0,0,0.79) inset;
    }

    .outcome {
        width: 100%;
        height: 24px;
        display: flex;
        justify-content: center;
        align-items: center;
        margin-top: 5px;
        background-color: #0e2e463a;
        border-radius: 0px 0px 8px 8px;
    }

    .outcome p {
        font-family: 'Bebas Neue', sans-serif;
        font-weight: 400;
        font-style: normal;
        color: white;
        font-size: 14px;
        margin: 0;
    }

    .passed {
        background-color: #2eee9473;
        color: #ffffff;
        box-shadow: 0px 0px 27px 0px rgba(0,0,0,0.79) inset;
        -webkit-box-shadow: 0px 0px 27px 0px rgba(0,0,0,0.79) inset;
        -moz-box-shadow: 0px 0px 27px 0px rgba(0,0,0,0.79) inset;
    }

    .failed {
        background-color: #ff686b88;
        color: #ffffff;
        box-shadow: 0px 0px 27px 0px rgba(0,0,0,0.79) inset;
        -webkit-box-shadow: 0px 0px 27px 0px rgba(0,0,0,0.79) inset;
        -moz-box-shadow: 0px 0px 27px 0px rgba(0,0,0,0.79) inset;
    }
</style>