/*
This is a cheat script for https://jklm.fun BombParty game
Directly pasting the script in the console may not work
Read the usage guide (https://github.com/MoBakour/jklm-bombparty-cheat)

Script by MoBakour (https://bakour.dev)
*/

(async (
    autotype = true,
    selfOnly = true,
    lang = "en",
    min = 15,
    max = 40,
    instant = false,
    pause = 30,
    initialPause = 700
) => {
    lang = lang.toLowerCase().trim();

    // constants
    const api = `https://random-word-api.herokuapp.com/all?lang=${lang}`;
    const supportedLanguages = ["en", "es", "it", "fr", "de"];
    const logFontSize = "font-size:16px;";
    const logStyles = {
        error: "color:crimson;" + logFontSize,
        success: "color:cyan;" + logFontSize,
        word: "color:green;" + logFontSize,
        myWord: "color:lime;" + logFontSize,
    };

    // fallback wordlists (the old heroku API is dead) -> way more words
    const FALLBACK_WORDLISTS = {
        en: [
            "https://raw.githubusercontent.com/dwyl/english-words/master/words_alpha.txt",
            "https://raw.githubusercontent.com/dolph/dictionary/master/popular.txt",
        ],
        es: ["https://raw.githubusercontent.com/words/an-array-of-spanish-words/master/index.json"],
        it: ["https://raw.githubusercontent.com/words/an-array-of-italian-words/master/index.json"],
        fr: ["https://raw.githubusercontent.com/words/an-array-of-french-words/master/index.json"],
        de: ["https://raw.githubusercontent.com/words/an-array-of-german-words/master/index.json"],
    };

    // elements
    const syllable = document.querySelector(".syllable");
    const selfTurn = document.querySelector(".selfTurn");
    const seating = document.querySelector(".bottom .seating");
    const input = document.querySelector(".selfTurn input");

    // variables
    let library;
    let word;
    let myTurn = false;

    // welcome logs
    console.log(
        "%cWelcome to jklm.fun BombParty cheat script",
        logStyles.success
    );
    console.log("%cBy MoBakour: https://bakour.dev", logStyles.success);
    console.log(
        "%cGithub repo: https://github.com/MoBakour/jklm-bombparty-cheat",
        logStyles.success
    );

    // validate options & environment
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

    /**
     * fetch library
     * 1) tries the original API (in case it comes back)
     * 2) falls back to big GitHub wordlists = more words
     * filter for min and max lengths, then shuffle
     */
    async function loadWords() {
        try {
            const res = await fetch(api, { signal: AbortSignal.timeout(6000) });
            if (res.ok) {
                const words = await res.json();
                const arr = words
                    .map((w) => String(w).trim().toLowerCase())
                    .filter((el) => el.length >= min && el.length <= max);
                if (arr.length > 100) return shuffle(arr);
            }
        } catch (e) { /* fall through to wordlists */ }

        const urls = FALLBACK_WORDLISTS[lang] || FALLBACK_WORDLISTS.en;
        for (const url of urls) {
            try {
                const res = await fetch(url, { signal: AbortSignal.timeout(15000) });
                if (!res.ok) continue;
                const raw = await res.text();
                const words = url.endsWith(".json")
                    ? JSON.parse(raw)
                    : raw.split(/\r?\n/);
                const arr = words
                    .map((w) => String(w).trim().toLowerCase())
                    .filter((el) => el.length >= min && el.length <= max);
                if (arr.length > 100) return shuffle(arr);
            } catch (e) { /* try next source */ }
        }
        return null;
    }

    /**
     * load library
     * filter for min and max lengths
     * shuffle words
     */
    try {
        library = await loadWords();
        if (!library) throw new Error("no source worked");

        console.log(
            `%cLibrary loaded (${library.length} words)`,
            logStyles.success
        );
    } catch (err) {
        console.log(
            "%cError: couldn't load words library! :(",
            logStyles.error
        );
        return;
    }

    /**
     * observer to detect changes in the .selfTurn and .seating elements attributes
     * we check the .seating element for `hidden` to make sure the game is started
     *
     * when own turn comes, a `hidden` attribute is removed from the .selfTurn element
     * we check that to determine whether its own turn
     */
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

    /**
     * An asynchronous function to stop the code for a specified amount of time
     * @param {number} time - pause duration in milliseconds
     * @returns {Promise}
     */
    function sleep(time) {
        return new Promise((res) => {
            setTimeout(res, time);
        });
    }

    /**
     * Function to shuffle array using the fisher-yates algorithm
     * @param {Array} array - Array to shuffle
     * @returns {Array}
     */
    function shuffle(array) {
        const arr = JSON.parse(JSON.stringify(array));
        let currentIndex = arr.length,
            randomIndex;

        // while there remain elements to shuffle
        while (currentIndex > 0) {
            // pick a remaining element
            randomIndex = Math.floor(Math.random() * currentIndex);
            currentIndex--;

            // and swap it with the current element
            [arr[currentIndex], arr[randomIndex]] = [
                arr[randomIndex],
                arr[currentIndex],
            ];
        }

        return arr;
    }

    /**
     * Function to type a word into the input letter by letter with a pause in between to make it more human-like
     * @param {string} word - A string of letters to type
     * @param {boolean} [triggered] - A boolean to distinguish between observer's call and user's control keydown call
     */
    async function typeLetters(word, triggered) {
        // initial pause
        if (!triggered) {
            await sleep(initialPause);
        }

        for (const char of word) {
            input.value = input.value + char;
            input.dispatchEvent(new Event("input", { bubbles: true }));

            // add margin in time to make it appear more human
            const margin = Math.random() * pause - pause / 2;
            await sleep(pause + margin);
        }
    }

    /**
     * Cheat function
     * @param {boolean} [triggered=false] - A boolean to distinguish between observer's call and user's control keydown call
     */
    async function cheat(triggered = false) {
        if (!library || (triggered && !myTurn)) return;

        if (!triggered) {
            const letters = syllable.innerText.toLowerCase();
            word = library.find((el) =>
                el.toLowerCase().includes(letters)
            );
        }

        if (!word) {
            console.log("%cError: failed to find a word ;-;", logStyles.error);
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

            // select input text so user has the immediate option to overwrite
            input.select();
        }

        // shuffle library after every cheat to prevent reuse of words
        library = shuffle(library);
    }

    // trigger cheat on control keydown
    window.addEventListener("keydown", (e) => {
        if (e.key === "Control") {
            cheat(true);
        }
    });
})();
