$(document).ready(function(){
	window.addEventListener("message",function(event){
		if (event.data.celular == true) {
			$("#displayBars").css('display', 'none');
			$("#displayVehicle").addClass("over-telefone");
		} else {
			$("#displayBars").css('display', 'block');
			$("#displayVehicle").removeClass("over-telefone");
		}

			//Normal & Car
		if (event.data.active == true) {
			$("#displayHud").css("display","block");
			$(".healthHover").css("width", parseInt(event.data.health) / 3 + "%");
			$(".armourHover").css("width", parseInt(event.data.armour) );


			if (parseInt(event.data.health) / 3 == 1) {
				$(".healthHover").css("width","0");
			}
			if (parseInt(event.data.armour) / 3 == 1) {
				$(".armourHover").css("width",event.data.armour + "%");
			}

			$("#displayInfos").html(event.data.day+"</b> de <b>"+event.data.month+"</b> - "+event.data.hour+":"+event.data.minute+"<br><b>"+event.data.street+"</b>");

			// Car

			if (event.data.vehicle == true) {
				$(".staminaOrGas").css("background", "url(images/gas.png) center no-repeat");
				$(".staminaOrGasHover").css("width", event.data.fuel + "%");
				$("#displayVehicle").css("display","block");
				$("#displayVehicleIcon").css("display","block");

				if (event.data.seatbelt == true) {
					$("#displayVehicle").addClass("seatbelt").html(event.data.speed+"<s>KMH</s>");
					$(".seatBeltIcon").css("background", "url(images/cinto2.png) center no-repeat");
		
				} else {
					$("#displayVehicle").removeClass("seatbelt").html(event.data.speed+"<b>KMH</b>");
					$(".seatBeltIcon").css("background", "url(images/cinto0.png) center no-repeat");

				}
			} else {
				$("#displayVehicle").css("display","none");
				$("#displayVehicleIcon").css("display","none");
				$(".staminaOrGas").css("background", "url(images/stamina.png) center no-repeat");
				$(".staminaOrGasHover").css("width", event.data.stamina + "%");
			}
		} else {
			$("#displayHud").css("display","none");
			$("#displayVehicle").css("display","none");
		}

		
			// 	

		if (event.data.movie == true){
			$("#movieTop").css("display","block");
			$("#movieBottom").css("display","block");
			$("#displayLogo").css("display","none");
		} else {
			$("#movieTop").css("display","none");
			$("#movieBottom").css("display","none");
			$("#displayLogo").css("display","block");
		}
	})
});