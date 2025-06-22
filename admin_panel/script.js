console.log("Hello");

const nodes = document.querySelectorAll(".nodes");
nodes.forEach(n => {
    n.addEventListener('click' , ()=>{
        const station = n.querySelector('span').textContent.trim();
        n.classList.add("active");
        window.location.href = `station_control.html?station=${encodeURIComponent(station)}`;
    });
});