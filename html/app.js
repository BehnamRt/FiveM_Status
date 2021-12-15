function rgba(hex,opacity){
    hex = hex.replace('#','');
    redColor = parseInt(hex.substring(0,2), 16);
    greenColor = parseInt(hex.substring(2,4), 16);
    blueColor = parseInt(hex.substring(4,6), 16);

    result = 'rgba('+redColor+','+greenColor+','+blueColor+','+opacity/100+')';
    return result;
}

var loadJS = function(url, implementationCode, location) {
	var scriptTag = document.createElement('script');
	scriptTag.src = url;

	scriptTag.onload = implementationCode;
	scriptTag.onreadystatechange = implementationCode;

	location.appendChild(scriptTag);
};



function ajaxio(method,url,type=null,data=null) {
	return new Promise((resolve, reject) => {
		const req = new XMLHttpRequest();
		req.open(method, url, true); 

		if (method == 'POST') {
			if (type == 'json' && data != null) {
				req.setRequestHeader('Content-Type', 'application/json');
				var data = JSON.stringify(data);
			}
			else { req.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded'); }
		}

		req.onload = () => req.status === 200 ? resolve(req.response) : reject(Error(req.statusText));
		req.onerror = (e) => reject(Error(`Network Error: ${e}`));

		if (method == 'POST') { req.send(data); }
		else { req.send(); }
	});
}


Object.prototype.addMultiListener = function(eventNames, listener) {
	var events = eventNames.split(' ');

	if (NodeList.prototype.isPrototypeOf(this) == true) {
		for (var x=0, xLen=this.length; x<xLen; x++) {
			for (var i=0, iLen=events.length; i<iLen; i++) { this[x].addEventListener(events[i], listener, false); }
		}
	}

	else if (HTMLElement.prototype.isPrototypeOf(this) == true) {
		for (var i=0, iLen=events.length; i<iLen; i++) { this.addEventListener(events[i], listener, false); }
	}
}


window.onload = function () {

		var eventCallback = {
			element: function(data) {
				if (data.task == 'enable') { document.querySelector('#'+data.value).style.display = 'block'; }
				else if (data.task == 'disable') { document.querySelector('#'+data.value).style.display = 'none'; }
			},
			setText: function(data) {
				var key = document.querySelector('#'+data.id+' span');
				var html = data.value;
				saferInnerHTML(key, html);
			},

			isTalking: function(data) {
				var voiceId = document.querySelector('#voice');
				if (data.value) { voiceId.classList.add('speak'); }
				else { voiceId.classList.remove('speak'); }
			},


			setVoiceDistance: function(data) {
				var voiceId = document.querySelector('#voice');
				var voiceIdWithClasses = voiceId.classList;

				voiceIdWithClasses.remove('whisper', 'normal', 'shout');
				voiceIdWithClasses.add(data.value);
			},


			createStatus: function(data) {

				var motherStatus = document.querySelector('div#status ul');

				var statusID = data.status;
				var statusPrimaryColor = rgba(data.color,100);
				var statusSecondaryColor = rgba(data.color,75);
				var statusIcon = data.icon + '<span style="background: linear-gradient(0deg, '+statusSecondaryColor+' 0%, '+statusPrimaryColor+' 100%);"></span>';


				if (document.getElementById(statusID)) { }
				else {
					var newStatus = document.createElement('li');
					newStatus.classList.add('icon', 'customstatus');
					newStatus.id = statusID;

					motherStatus.insertBefore(newStatus, motherStatus.firstChild);

					saferInnerHTML(document.getElementById(statusID), statusIcon);
				}
			},


			setStatus: function(data) {

				if (data.isdead == true) {
					if (document.querySelector('#health').classList.contains('dead') == false) {
						document.querySelector('#health').classList.add('dead');
						for (i = 0; i < data.status.length; i++) { document.querySelector('#'+data.status[i].name+' span').style.height = '0'; }	
					}
				}
				else {
					for (i = 0; i < data.status.length; i++) {
						if ((data.status[i].name == 'hunger') || (data.status[i].name == 'thirst') || (data.status[i].name == 'drunk')) { var statusValue = Math.floor(100 - data.status[i].value); }
						else { var statusValue = Math.floor(data.status[i].value); }
						if (document.querySelector('#'+data.status[i].name+' span')) { document.querySelector('#'+data.status[i].name+' span').style.height = statusValue+'%'; }
						if (statusValue <= 35) {
							if (document.querySelector('#'+data.status[i].name)) {
								if (document.querySelector('#'+data.status[i].name).classList.contains('dying') == false) {
									document.querySelector('#'+data.status[i].name).classList.add('dying');	
								}
							}
						}
						else {
							if (document.querySelector('#'+data.status[i].name)) { document.querySelector('#'+data.status[i].name).classList.remove('dying'); }
							
						}
					}
					if (document.querySelector('#health').classList.contains('dead')) { document.querySelector('#health').classList.remove('dead'); }
				}
			},


			updateWeapon: function(data) {
				var weaponContainer = document.querySelector('#weapon');
				var bulletsContainer = document.querySelector('#bullets');

				if (data.status.armed == true) {

					var oldWeapon = document.querySelector('#weapon_image img').src;
					var newWeapon = 'img/weapons/'+data.status.weapon+'.png';
					if (oldWeapon != newWeapon) {  document.querySelector('#weapon_image img').src = newWeapon; }

					if (weaponContainer.classList.contains('armed') == false) {
						weaponContainer.classList.remove('unarmed', 'fadeOut');
						weaponContainer.classList.add('armed', 'fadeIn');
					}
					
				}
				else {

					if (weaponContainer.classList.contains('unarmed') == false) {
						weaponContainer.classList.remove('armed', 'fadeIn');
						weaponContainer.classList.add('unarmed', 'fadeOut');
					}
					
				}
			},






			updateVehicle: function(data) {

				var vehicleInfo = document.querySelector('.info.vehicle');
				var vehicleLights = document.querySelector('#lights');
				var vehicleFuel = document.querySelector('#fuel');
				var vehicleCruiser = document.querySelector('#vehicle-speed strong');
				var vehiclesCars = [0,1,2,3,4,5,6,7,8,9,10,11,12,17,18,19,20];

				if (data.status == true) {
					if (vehicleInfo.classList.contains('inactive')) {

						vehicleLights.style.display = 'none';
						vehicleFuel.style.display = 'none';

						if (vehiclesCars.indexOf(data.type) > -1) {
							document.querySelector('#vehicle-others').style.display = 'none';
							document.querySelector('#vehicle-gear').style.display = 'block';

							vehicleLights.style.display = 'block';
							vehicleFuel.style.display = 'block';
							
							document.querySelector('#vehicle-gear').style.display = 'block';
						}

						else {
							document.querySelector('#vehicle-others').style.display = 'block';
							document.querySelector('#vehicle-gear').style.display = 'none';
							document.querySelector('#vehicle-others i').classList.remove('fa-biking', 'fa-helicopter', 'fa-ship');

							if (data.type == 13) { document.querySelector('#vehicle-others i').classList.add('fa-biking'); } 
							else if (data.type == 14) { document.querySelector('#vehicle-others i').classList.add('fa-ship'); } 
							else if (data.type == 15) { document.querySelector('#vehicle-others i').classList.add('fa-helicopter'); }
							else if (data.type == 16) { document.querySelector('#vehicle-others i').classList.add('fa-plane'); } 
							else if (data.type == 21) { document.querySelector('#vehicle-others i').classList.add('fa-train'); } 
						}

						vehicleInfo.classList.remove('inactive');
						vehicleInfo.classList.add('active', 'fadeIn');
					}

					if (vehicleInfo.classList.contains('updated') == false) {

						var vehicleSpeedUnit = data.config.speedUnit.slice(0,2)+'/'+data.config.speedUnit.slice(-1);
						var vehicleAverageSpeed = Math.ceil(data.config.maxSpeed / 6);

						vehicleInfo.classList.add('updated');
						saferInnerHTML(vehicleCruiser,vehicleSpeedUnit);

					}




					var previousGear = document.querySelector('#vehicle-gear span').innerHTML;
					var currentGear = data.gear;
					if (previousGear != currentGear) { document.querySelector('#vehicle-gear').classList.add('pulse') }
					saferInnerHTML(document.querySelector('#vehicle-gear span'), data.gear);






					var speedometerCircle = document.querySelector('#progress-speed svg circle.speed');
					var speedPercentage = Math.floor(Math.floor(data.speed*100)/data.config.maxSpeed);
					
					speedometerCircle.classList.remove('zero');
					speedometerCircle.classList.remove('twentyfive');
					speedometerCircle.classList.remove('fifty');
					speedometerCircle.classList.remove('seventyfive');

					if (speedPercentage >= 0 && speedPercentage <= 25) { speedometerCircle.classList.add('zero'); }
					else if (speedPercentage > 25 && speedPercentage <= 50) { speedometerCircle.classList.add('twentyfive'); }
					else if (speedPercentage > 50 && speedPercentage <= 75) { speedometerCircle.classList.add('fifty'); }
					else if (speedPercentage > 75) { speedometerCircle.classList.add('seventyfive'); }

					document.querySelector('#progress-speed svg circle.speed').style.strokeDashoffset = data.nail;
					saferInnerHTML(document.querySelector('#vehicle-speed span'), data.speed);










					if (vehicleCruiser.classList.contains(data.cruiser) == false) {
						vehicleCruiser.classList.remove('on','off');
						vehicleCruiser.classList.add(data.cruiser);
					}




					if (data.siren == true) { document.querySelector('#vehicle-gear').classList.add('pulsing'); }
					else { document.querySelector('#vehicle-gear').classList.remove('pulsing'); }






					if (vehicleLights.classList.contains(data.lights) == false) {
						vehicleLights.classList.remove('normal','high','off');
						vehicleLights.classList.add(data.lights);

						if (data.lights == 'high') { vehicleLights.querySelector('i img').src = 'img/vehicle-lights-high.png'; }
						else { vehicleLights.querySelector('i img').src = 'img/vehicle-lights.png'; }
					}





					vehicleFuel.querySelector('span').style.height = data.fuel+'%';

					if (data.fuel <= 35) {
						if (vehicleFuel.classList.contains('dying') == false) { vehicleFuel.classList.add('dying');	}
					}
					else { vehicleFuel.classList.remove('dying'); }

				}
				else {
					if (vehicleInfo.classList.contains('active')) {
						vehicleCruiser.classList.remove('on');

						vehicleInfo.classList.remove('active');
						vehicleInfo.classList.add('inactive', 'fadeOut');
					}

				}
				
			},
			
			toggleUi: function(data) {
				var uiID = document.querySelector('#ui');
				if (data.value == true) {
					uiID.style.display = 'block';
				}
				else {
					uiID.style.display = 'none';
				}
			},

		};

		document.querySelectorAll('.icon i').addMultiListener('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function () { this.parentElement.classList.remove('pulse'); this.parentElement.classList.remove('shooting'); });

		document.querySelectorAll('.info.vehicle').addMultiListener('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function () {
			this.classList.remove('fadeOut', 'fadeIn');
		});


		window.addEventListener('message', function(event) {
			if (event.data.action == "setValue"){
				if (event.data.key == "job"){
					$('#job img').attr('src', 'img/jobs/'+event.data.icon+'.png')
				} else if (event.data.key == "gang"){
					$('#gang img').attr('src', event.data.icon2)
				}
				$('#'+event.data.key+' span').html(event.data.value)
			} else {
				eventCallback[event.data.action](event.data);
			}
		});

}