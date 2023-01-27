const petiteDirectives = [
    "v-scope",
    "v-effect",
    "v-bind",
    "v-on",
    "v-model",
    "v-if",
    "v-else",
    "v-else-if",
    "v-for",
    "v-show",
    "v-html",
    "v-text",
    "v-pre",
    "v-once",
    "v-cloak"
];

const prefixedDirectives = petiteDirectives.map((v) => {
    return `data-${v}`;
})

function removePrefix(str) {
    return str.slice(5);
}

document.addEventListener("DOMContentLoaded", function() {
    document.querySelectorAll("*").forEach(element => {
        prefixedDirectives.forEach((v) => {
            if (element.hasAttribute(v)) {
                const attr = element.getAttribute(v);
                element.removeAttribute(v)
                element.setAttribute(removePrefix(v), attr)
            }
        })
    });

    PetiteVue.createApp().mount()
})
