

#Constructs a random element with a fixed boundary size s+-margin in a group G
RandomElementFixedBoundarySize:=function(s,margin,G)
	local g, cur_length, bndry_size;
	cur_length:=5*s;
	repeat
		g:=RandomElement(cur_length,G);
		bndry_size:=Length(AutomPortraitBoundary(g));
		if bndry_size<=s+margin and s-margin<=bndry_size then return g; 
			elif bndry_size>s+margin then cur_length:=cur_length-1;
			else cur_length:=cur_length+1;
		fi;
	until false;
end;



# k = number of elements in the public key for alice and bob.
# l = word length of elements in the public key alice and bob.
# r_length = word length of the private keys of alice and bob.
# degree = degree of group used for aag.
# group = group used of aag.

aag_key_generator := function(k , l , r_length , group )
    local i , j , public_bob , private_bob_base, private_bob_exps, private_bob, public_alice , private_alice_base, private_alice_exps, private_alice, key_alice, key_bob, alice_to_bob, bob_to_alice ;

    public_alice := List([1..k],x->RandomElement(l,group));
	private_alice_base:=List([1..r_length],x->Random([1..k]));
	private_alice_exps:=List([1..r_length],x->Random([-1,1]));
    private_alice := Product(List([1..r_length],x->public_alice[private_alice_base[x]]^private_alice_exps[x]));

    public_bob := List([1..k],x->RandomElement(l,group));;
	private_bob_base:=List([1..r_length],x->Random([1..k]));
	private_bob_exps:=List([1..r_length],x->Random([-1,1]));
    private_bob := Product(List([1..r_length],x->public_bob[private_bob_base[x]]^private_bob_exps[x]));

	alice_to_bob:=List(public_bob,x->x^private_alice);
	bob_to_alice:=List(public_alice,x->x^private_bob);

	key_alice := private_alice^-1*Product(List([1..r_length],x->bob_to_alice[private_alice_base[x]]^private_alice_exps[x]));
	key_bob := Product(List([1..r_length],x->alice_to_bob[private_bob_base[x]]^private_bob_exps[x]))^-1*private_bob;
	
	return [key_alice, key_bob, key_alice=key_bob] ;
end;

aag_key_generator_transmission := function(k , s, margin, r_length, group )
    local i , j , public_bob , private_bob_base, private_bob_exps, private_bob, public_alice , private_alice_base, private_alice_exps, private_alice, key_alice, key_bob, alice_to_bob, bob_to_alice ;

    public_alice := List([1..k],x->RandomElementFixedBoundarySize(s,margin,group));
	private_alice_base:=List([1..r_length],x->Random([1..k]));
	private_alice_exps:=List([1..r_length],x->Random([-1,1]));
    private_alice := Product(List([1..r_length],x->public_alice[private_alice_base[x]]^private_alice_exps[x]));

    public_bob := List([1..k],x->RandomElementFixedBoundarySize(s,margin,group));;
	private_bob_base:=List([1..r_length],x->Random([1..k]));
	private_bob_exps:=List([1..r_length],x->Random([-1,1]));
    private_bob := Product(List([1..r_length],x->public_bob[private_bob_base[x]]^private_bob_exps[x]));

	alice_to_bob:=List(public_bob,x->x^private_alice);
	bob_to_alice:=List(public_alice,x->x^private_bob);
	key_alice := private_alice^-1*Product(List([1..r_length],x->bob_to_alice[private_alice_base[x]]^private_alice_exps[x]));
	
	return [alice_to_bob, bob_to_alice,key_alice] ;
end;


#for 1024-bit: 8, 12,0,50, G   8 elements in open key, 12+-0 - size of the boudary of portraits, 50 - length of a conjugator
#for 2048-bit: 16,11,0,100,G
aag_transmission_size:=function(k , s, margin, r_length, group )
	local tr;
	tr := aag_key_generator_transmission(k , s, margin, r_length, group);
	return [List(tr[1],x->Length(AutomPortraitBoundary(x))),Length(AutomPortraitBoundary(tr[3]))];
end;