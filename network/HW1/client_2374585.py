import requests
import json
import random

def simulate_dhondt(region_name, party_percentages):
    url = "http://127.0.0.1:5000/election/simulate"
    data = {"region": region_name, **party_percentages}
    response = requests.post(url, json=data)
    result = response.json()
    print(f"MP distribution for {region_name}:")
    for party, seats in result.items():
        print(f"{party}: {seats} seats")

if __name__ == "__main__":
    res = requests.get('http://127.0.0.1:5000/election/regions')			# region list
    response = json.loads(res.text)
    print("List of regions:",response)
    print()
   
    region_new = {"region_name": "METU", "number_of_seats": 10}  # Correct the key name		# add METU region with 10 seats
    res = requests.put('http://127.0.0.1:5000/election/regions', json=region_new)
    print("Response to new region METU:", res.text)
    print()

    region_new = {"region_name": "EEE", "number_of_seats": 3}  				# add EEE region with 3 seats
    res = requests.put('http://127.0.0.1:5000/election/regions', json=region_new)
    print("Response to new region EEE:", res.text)
    print()
    

    region_new={"region_name":"METU", "number_of_seats": 10}				# readd METU
    res=requests.put('http://127.0.0.1:5000/election/regions', json=region_new)
    print("Response to readd METU:", res.text)
    print()
    print("Status code of METU:", res.status_code)
    print()
    
    dlt={"region_name": "EEE"}												# delete METU
    res=requests.delete('http://127.0.0.1:5000/election/regions', json=dlt)
    print("Response to delete EEE:", res.text)
    print()
    
    res = requests.get('http://127.0.0.1:5000/election/parties')			# parties list
    response = json.loads(res.text)
    print("List of parties:",response)
    print()
    
    party_new = {"party_name":"Party1"}											# add Party1
    res = requests.put('http://127.0.0.1:5000/election/parties',json=party_new)
    print("Response to new Party1:",res.text)
    print()
    
    party_new = {"party_name":"Party2"}											# add Party2
    res = requests.put('http://127.0.0.1:5000/election/parties',json=party_new)
    print("Response to new Party2:",res.text)
    print()
    
    party_new = {"party_name":"Party3"}											# add Party3
    res = requests.put('http://127.0.0.1:5000/election/parties',json=party_new)
    print("Response to new Party3:",res.text)
    print()
    
    party_new = {"party_name":"Party4"}											# add Party4
    res = requests.put('http://127.0.0.1:5000/election/parties',json=party_new)
    print("Response to new Party4:",res.text)
    print()
    
    party_new = {"party_name":"Party4"}											# readd Party4
    res = requests.put('http://127.0.0.1:5000/election/parties',json=party_new)
    print("Status code of Party4:",res.text)
    print()
    
    party_delete = {"party_name":"Party4"}										# delete Party4
    res = requests.delete('http://127.0.0.1:5000/election/parties',json=party_delete)
    print("Response to delete Party4:",res.text)
    print()
    
    res = requests.get('http://127.0.0.1:5000/election/parties')			# remaining parties list
    response = json.loads(res.text)
    print("Remaining parties list:",response)
    print()
    
    
    regions_url = "http://127.0.0.1:5000/election/regions"
    regions_response = requests.get(regions_url)            # list of regions
    regions = regions_response.json()

    selected_regions = random.sample(regions, 3)        # random select regions

    
    for region in selected_regions:
        region_name = region["region_name"]
        party_percentages = {"Party1": 22, "Party2": 34, "Party3": 58}  # vote percentages given by myself
        
   
        simulate_dhondt(region_name, party_percentages)

