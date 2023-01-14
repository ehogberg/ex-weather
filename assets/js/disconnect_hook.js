export const DisconnectHooks = {
    mounted() {
        console.log("mounted")
        let cached_stations = sessionStorage.getItem("station-id-cache") || ""
        this.pushEvent("load_stations", {cached_stations: cached_stations})
    },
    disconnected() {
        let children = this.el.getElementsByClassName("station-component")
        var stations = [...children].map(function (el) {
            return el.dataset.stationname
        })
        stations = stations.join("|")
        sessionStorage.setItem("station-id-cache",stations)
    },
    reconnected() {
        console.log("Reconnected");
        let cached_stations = sessionStorage.getItem("station-id-cache") || ""
        this.pushEvent("load_stations", {cached_stations: cached_stations})
        sessionStorage.removeItem("station-id-cache")
    }
}