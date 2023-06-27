function sat_vap_pres = e_saturation(temperature, phase)
    % Output in Pa
    % Using the improved magnus equation
    % Huang, J., 2018: A Simple Accurate Formula for Calculating Saturation Vapor Pressure of Water and Ice. J. Appl. Meteor. Climatol., https://doi.org/10.1175/JAMC-D-17-0334.1. 
    T = temperature;
    
    if phase == "ice"
        sat_vap_pres = 611.21*exp((22.587*T)/(T+273.86))*0.01;
    else 
        disp("vapor pressure over liquid water");
        sat_vap_pres = 610.94*exp((17.625*T)/(T+243.04))*0.01;
    end

end