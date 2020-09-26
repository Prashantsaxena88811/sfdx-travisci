({
    afterRender: function(c, e,h) {
        this.superAfterRender();
        document.getElementById("mySidenav").style.width = "100%";
       
        document.getElementById("assetfilter").style.width = "18%";
        document.getElementById("assetbody").style.width = "82%";
        document.getElementById("assetfilterspan").classList.add("displaynone");
        
        //document.getElementById("mySidenavRight").style.width = "15rem";
        document.getElementById("mySidenavRight").classList.remove("displaynone");
        
    }
})