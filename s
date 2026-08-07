```js
(async (
    autotype = true,
    selfOnly = true,
    lang = "en",
    min = 6,
    max = 20,
    instant = false,
    pause = 100,
    initialPause = 700
) => {
    lang = lang.toLowerCase().trim();

    const api = `https://random-word-api.herokuapp.com/all?lang=${lang}`;
    const supportedLanguages = ["en", "es", "it", "fr", "de"];
    const logFontSize = "font-size:16px;";
    const logStyles = {
        error: "color:crimson;" + logFontSize,
        success: "color:cyan;" + logFontSize,
        word: "color:green;" + logFontSize,
        myWord: "color:lime;" + logFontSize,
    };

    const syllable = document.querySelector(".syllable");
    const selfTurn = document.querySelector(".selfTurn");
    const seating = document.querySelector(".bottom .seating");
    const input = document.querySelector(".selfTurn input");

    let library;
    let word;
    let myTurn = false;

    console.log(
        "%cWelcome to jklm.fun BombParty cheat script",
        logStyles.success
    );
    console.log("%cBy MoBakour: https://bakour.dev", logStyles.success);
    console.log(
        "%cGithub repo: https://github.com/MoBakour/jklm-bombparty-cheat",
        logStyles.success
    );

    let error;

    if (!syllable || !selfTurn)
        error =
            "incorrect javascript context, please switch to 'bombparty/' javascript context. Read the usage guide.";

    if (!supportedLanguages.includes(lang))
        error = `supported languages are: ${supportedLanguages.join(", ")}`;

    if (isNaN(min) || isNaN(max) || min < 1 || max < 1)
        error = "min and max values must be numerical values greater than 0";

    if (max < min) error = "max cannot be less than min";

    if (isNaN(pause)) error = "pause must be a number";

    if (isNaN(initialPause))
        error = "initialPause must be a number";

    if (error) {
        console.log(`%cError: ${error}`, logStyles.error);
        return;
    }

    try {
        library = await (await fetch(api)).json();
        library = library.filter(
            (el) => el.length >= min && el.length <= max
        );
        library = shuffle(library);

        console.log("%cLibrary loaded 👍", logStyles.success);
    } catch (err) {
        console.log(
            "%cError: couldn't load words library! :(",
            logStyles.error
        );
        return;
    }

    const observer = new MutationObserver(() => {
        if (seating.getAttribute("hidden") === null) return;

        myTurn = selfTurn.getAttribute("hidden") === null;
        cheat();
    });

    observer.observe(selfTurn, {
        attributes: true,
    });

    observer.observe(seating, {
        attributes: true,
    });

    function sleep(time) {
        return new Promise((res) => {
            setTimeout(res, time);
        });
    }

    function shuffle(array) {
        const arr = JSON.parse(JSON.stringify(array));
        let currentIndex = arr.length;
        let randomIndex;

        while (currentIndex > 0) {
            randomIndex = Math.floor(Math.random() * currentIndex);
            currentIndex--;

            [arr[currentIndex], arr[randomIndex]] = [
                arr[randomIndex],
                arr[currentIndex],
            ];
        }

        return arr;
    }

    async function typeLetters(word, triggered) {
        if (!triggered) {
            await sleep(initialPause);
        }

        for (const char of word) {
            input.value = input.value + char;
            input.dispatchEvent(
                new Event("input", { bubbles: true })
            );

            const margin = Math.random() * pause - pause / 2;
            await sleep(pause + margin);
        }
    }

    async function cheat(triggered = false) {
        if (!library || (triggered && !myTurn)) return;

        if (!triggered) {
            const letters = syllable.innerText.toLowerCase();
            word = library.find((el) =>
                el.toLowerCase().includes(letters)
            );
        }

        if (!word) {
            console.log(
                "%cError: failed to find a word ;-;",
                logStyles.error
            );
            return;
        }

        if ((!selfOnly || myTurn) && !triggered) {
            console.log(
                `%c${word}`,
                myTurn ? logStyles.myWord : logStyles.word
            );
        }

        if ((autotype && myTurn) || triggered) {
            if (instant) {
                input.value = word;
            } else {
                await typeLetters(word, triggered);
            }

            input.select();
        }

        library = shuffle(library);
    }

    window.addEventListener("keydown", (e) => {
        if (e.key === "Control") {
            cheat(true);
        }
    });
})();
```
