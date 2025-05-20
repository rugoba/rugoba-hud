const playerHud = {
    data() {
        return {
            health: 0,
            armor: 0,
            hunger: 0,
            thirst: 0,
            show: false,

            showHealth: true,
            showArmor: true,
            showHunger: true,
            showThirst: true,
            showStress: true,
            voiceLevel: 'low',
            isTalking: false,
            inVeh: false,
            radius: 10 
        }
    },
    destroyed() {
        window.removeEventListener('message', this.listener);
    },
    mounted() {
        this.listener = window.addEventListener('message', (event) => {
            if (event.data.action === 'hudtick') {
                this.hudTick(event.data);
            }
        });
    },
    computed: {
     
        progressPath() {
            const startX = 10; 
            const startY = 45; 
            const endX = 90; 
            const endY = 45;
            const largeArcFlag = (this.armor >= 50) ? 1 : 0; 
            return `M ${startX} ${startY} Q 50 5, ${endX} ${endY} A ${this.radius} ${this.radius} 0 ${largeArcFlag} 1 ${endX} ${endY}`; 
        },
     
        dashArray() {
            return 100; 
        },
     
        dashOffset() {
            const progress = (this.armor / 100) * this.dashArray; 
            return this.dashArray - progress; 
        },
    },
    methods: {
        hudTick(data) {
            this.show = data.show;
            this.health = data.health;
            this.armor = data.armor;
            this.hunger = data.hunger;
            this.thirst = data.thirst;
            this.isTalking = data.isTalking;
            this.inVeh = data.inVeh;
      
            switch (data.voice) {
                case 1.5:
                    this.voiceLevel = 'low'; 
                    break;
                case 3:
                    this.voiceLevel = 'medium';
                    break;
                case 6:
                    this.voiceLevel = 'high';
                    break;
                default:
                    this.voiceLevel = 'low'; 
            }
            
            if (this.isTalking == 1) {
                this.addTalkingAnimation();
            } else {
                this.removeTalkingAnimation();
            }
        },
        addTalkingAnimation() {
            const prostasElement = document.getElementById("prostas");
            if (prostasElement) {
                prostasElement.classList.add('shake');
            }
        },
    
        removeTalkingAnimation() {
            const prostasElement = document.getElementById("prostas");
            if (prostasElement) {
                prostasElement.classList.remove('shake');
            }
        },
        increaseHealth() {
            if (this.armor < 100) {
                this.armor += 10; 
            }
        },
        decreaseHealth() {
            if (this.armor > 0) {
                this.armor -= 10; 
            }
        },
    }
}

const app = Vue.createApp(playerHud);
app.use(Quasar)
app.mount('#ui-container');