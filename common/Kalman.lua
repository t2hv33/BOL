local function isnan(x) 
    if (x ~= x) then
        return true;
    end;

    if type(x) ~= "number" then
       return false; 
    end;

    if tostring(x) == tostring((-1)^0.5) then
        return true; 
    end;
    return false;
end

class 'Kalman' -- {
   function Kalman:__init()
      self.current_state_estimate = 0
      self.current_prob_estimate = 0
      self.Q = 1--0.1
      self.R = 15--15    
   end

   function Kalman:step(control_vector, measurement_vector)
      --[[if isnan(measurement_vector) then
         --print("Nan error")
         return -1
      end
      if measurement_vector < 0 then
         --print("Very low value < 0")
         measurement_vector = 0
      end 
      if measurement_vector > 10000 then
         --print("Very high value > 10000")
         measurement_vector = 10000
      end ]]
      
      local predicted_state_estimate = self.current_state_estimate + control_vector
      local predicted_prob_estimate = self.current_prob_estimate + self.Q
      local innovation = measurement_vector - predicted_state_estimate
      local innovation_covariance = predicted_prob_estimate + self.R
      local kalman_gain = predicted_prob_estimate / innovation_covariance
      self.current_state_estimate = predicted_state_estimate + kalman_gain * innovation
      self.current_prob_estimate = (1 - kalman_gain) * predicted_prob_estimate
      return self.current_state_estimate
   end      