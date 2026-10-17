
$(function () {
    var isFileUrl = window.location;
    var strUrl = isFileUrl.toString();
    if (!((strUrl.indexOf("genomics.cn/NGS") >= 0) || (strUrl.indexOf("192.168.") >= 0))) {       
        $(".toHtml").each(function () {
            var link = $(this).attr("url");
            if (link.indexOf("Files") >= 0) {
                $(this).hide();
            }
        });
    }
    
    
    
    var url = GetQueryString("demo");

    if (url == 1) {

        $(".toHtml").each(function () {
            var link = $(this).attr("url");
            $(this).attr("url", link + "?demo=1");


        });
        $(".download1").hide();
        $(".rightline").each(function () {
            if ($(this).find("img").attr("alt") == "PDF") {
                $(this).hide();
            }
        });
    }
    $("ul.left_ul li").each(function () {
        $(this).mouseenter(function () {
            $(this).addClass("menuBG1");
        })
        $(this).mouseleave(function () {
            $(this).removeClass("menuBG1");
        })
    });
    $(".key_sign").each(function () {
        $(this).hover(function () {


            var top = $(this).offset().top;
            var left = $(this).offset().left;
            $(this).children("div.key_body").css("top", top + 20 + "px");
            $(this).children("div.key_body").css("left", left - 40 + "px");
            $(this).children("div.key_body").show();
        }, function () {
            $(this).children("div.key_body").hide();


        });



    });
    $(".key_sign_tb").each(function () {
        $(this).hover(function () {
            var id = $(this).attr("id");
            var newid = "s" + id;

            var top = $(this).offset().top;
            var left = $(this).offset().left;
            var height = $(this).children("div.key_body").height();

            $(this).children("div.key_body").css("top", top - height - 7 + "px");
            $(this).children("div.key_body").css("left", left - 40 + "px");
            $(this).children("div.key_body").show();
        }, function () {
            $(this).children("div.key_body").hide();


        });



    });
    setAutoScreen();
    setFontSize();
    siderTable();
    var left = $(".albumSlider-t table").width();
    $(".albumSlider-t .slider").css("left", left + "px");
    $("table").each(function () {
        $(this).find("tr:even").css("background-color", "#f1f5f8");
    });
    $(".b_lbut").toggle(function () {

        if ($(this).hasClass("b_lbut_fixer")) {
            $(this).removeClass("left238");
            $(this).addClass("left0");

        }
        $(this).removeClass("left_close");
        $(this).addClass("left_close1");


        $(this).prev(".move_left").hide(300);
        $(".content").css('width', 98 + "%");
        $(".content").css('padding-top', 10 + "px");
        $(".content").animate({ 'margin-left': 10 }, { duration: 800 });

    }, function () {

        if ($(this).hasClass("b_lbut_fixer")) {
            $(this).removeClass("left0");
            $(this).addClass("left238");
        }
        $(this).removeClass("left_close1");
        $(this).addClass("left_close");

        $(this).prev(".move_left").show(300);
        $(".content").animate({ 'margin-left': 257 }, { duration: 300 });
        var screenWidth = window.screen.width;
        if (screenWidth = 1024) {
            var w1 = screenWidth - 257 - 40;
            $(".content").css('width', w1 + "px");
        }
        $(".content").css('padding-top', 20 + "px");

    });
    $("ul.left_ul span").click(function () {
        $(this).parent().find("ul:first").slideToggle(300);
        if ($(this).hasClass("click")) {
            $(this).removeClass("click");
        }
        else {
            $(this).addClass("click");
        }
    });
    $('.toHtml').click(function () {
        var url = $(this).attr('url');
        if (url == "http://www.bgitechsolutions.cn") {
            window.open(url);
        } else {
            if ($(this).hasClass("File")) {
                window.open(url);
            } else {
                location.href = url;
            }
        }
    });

    $(".nav_ul > li").hover(function () {
        hv_obj = this;
        timeout = setTimeout(function () {
            $(hv_obj).addClass("li_hv");
            $(hv_obj).find(".nav_cul").slideDown(300);
        }, 300);
    }, function () {
        clearTimeout(timeout);
        $(hv_obj).removeClass("li_hv");
        $(hv_obj).find(".nav_cul").slideUp(300);
    });
    $(".nav_cul li").hover(function () {
        $(this).addClass("li_hv");
    }, function () {
        $(this).removeClass("li_hv");
    });
    //横向设置
    //$('div.albumSlider').albumSlider({ direction: 'h', step: 1 });


});
function setAutoScreen() {
    var screenWidth = window.screen.width;
    var screenHeight = window.screen.height;
    var height = $(".content").height();
    if (screenHeight >= 1024) {
        $("ul.left_ul").css("min-height", 790 + "px");
        if (height < 790) {
            $(".footer").css("margin-top", screenHeight - height - 60 + "px");
        }
    } else {
        if (height < 710) {
            $(".footer").css("margin-top", screenHeight - height - 60 + "px");
        }
    }
    if (screenWidth > 1000 && screenWidth <= 1280) {
        $("#page").css("min-width", 1001 + "px");
        $(".header").css("min-width", 1001 + "px");
        $(".menu").css("min-width", 1001 + "px");
        $(".link").css("left", screenWidth - 140 + "px");
        $(".top").css("left", screenWidth - 140 + "px");
        var rightw = screenWidth - 1267;
        if (rightw < 100) {
           
            $(".content").css("max-width", "900px");
        }
    }
    if (screenWidth > 1280) {
        var rightw = screenWidth - 1267;      
        if (rightw < 100) {
            $(".content").css("max-width", "900px");
        }
        $(".content").css("min-width", "1000px");
        $(".link").css("left", screenWidth - 140 + "px");
        $(".top").css("left", screenWidth - 140 + "px");
    }
    if (screenWidth < 1000) {
        $("#page").css("min-width", screenWidth + "px");
        $(".header").css("min-width", screenWidth + "px");
        $(".header .title").css("font-size", "26px");
        $(".content").css("max-width", screenWidth - 277 + "px");
        $(".link").css("left", screenWidth - 140 + "px");
        $(".top").css("left", screenWidth - 140 + "px");
    }
}
function setFontSize() {
    var Sys = {};
    var ua = navigator.userAgent.toLowerCase();
    var s;
    (s = ua.match(/msie ([\d.]+)/)) ? Sys.ie = s[1] :
        (s = ua.match(/firefox\/([\d.]+)/)) ? Sys.firefox = s[1] :
        (s = ua.match(/chrome\/([\d.]+)/)) ? Sys.chrome = s[1] :
        (s = ua.match(/opera.([\d.]+)/)) ? Sys.opera = s[1] :
        (s = ua.match(/version\/([\d.]+).*safari/)) ? Sys.safari = s[1] : 0;
    if (Sys.firefox) {
        $(".left_top").css("font-size", "14px");
        $("ul.left_ul li>a").css("font-size", "13px");
        $(".top").click(function () {
            $(window).scrollTop(0);

        });
    }
    if (Sys.chrome) {
        $(".fright").css("margin-left", "50%");
    }
    if(Sys.ie){
        var height = document.documentElement.clientHeight 
	var topHeight = $(".left_top").height();
	if(height>780){
	    $(".left_ul").css("min-height",height-topHeight+"px");
			
	}
		
    }	
}
function siderTable() {
    var num = 1;
    var count = $(".imglist").find("img").length;
    var top = 0;
    $(".movebackward").click(function () {
        count = $(this).next().find("li").length;
        // alert(top);

        var top1 = $(this).next().offset().top;
        //alert(top1);
        if (top1 != top) {
            num = 1;

        }
        top = top1;
        //alert(num);
        if (num > 1) {
            $(this).next().children().animate({ top: "+=" + 42 }, 500);
        }
        num--;
        if (num < 1) {
            num = 1;
        }
    });
    $(".moveforward").click(function () {
        count = $(this).prev().find("li").length;

        var top1 = $(this).prev().offset().top;

        if (top1 != top) {
            num = 1;

        }
        top = top1;
        if (count > num + 3) {
            // $(".imglist").animate({ left: "-=" + 115 }, 1000);
            $(this).prev().children().animate({ top: "-=" + 42 }, 500);
        }
        num++;
        if (num + 3 > count) {
            num = count - 3;
        }
    });
    $(".albumSlider-t .slider").find("li").each(function () {
        $(this).hover(function () {
            var i = $(this).index();

            $(this).parents("div.albumSlider-t").children(".fullview").find("li").each(function () {
                if ($(this).index() == i) {
                    $(this).removeClass("hide");
                    $(this).addClass("show");

                    $(this).prevAll().removeClass('show').addClass('hide');
                    $(this).nextAll().removeClass('show').addClass('hide');
                }

            });




        }, function () {


        });

    })
    $("ul.imglist").find("li").each(function () {
        $(this).bind("click", function () {
            var i = $(this).index();
            $(this).addClass("current");
            $(this).siblings().removeClass("current");
            $(this).parents("div.lane").next().children("span").eq(i).show();
            $(this).parents("div.lane").next().children("span").eq(i).prevAll().hide();
            $(this).parents("div.lane").next().children("span").eq(i).nextAll().hide();
            var img_src = $(this).attr("href");
            $(this).parents("div.slider").prev().children("a").attr("href", img_src);
            $(this).parents("div.slider").prev().children("a").children("img").attr("src", img_src);
        })

    })


}
function GetQueryString(sProp) {

    var re = new RegExp("[&,?]" + sProp + "=([^//&]*)", "i");

    var a = re.exec(document.location.search);

    if (a == null)

        return "";

    return a[1];

}

