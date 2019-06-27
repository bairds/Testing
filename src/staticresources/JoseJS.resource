var loading = false;

function showLoading(id)
{
	var element = document.getElementById('loading_request_' + id);
    // element.style.display = 'flex';
    loading = true;
    
    return element;
}

function hideLoading(id)
{
	document.getElementById('loading_request_' + id).style.display = 'none';
    loading = false;
}

function dump(obj) 
{
    var out = '';
    
    for(var i in obj)
        out += i + ": " + obj[i] + "\n";

    alert(out);
}

function setDisplay(id, value)
{
    document.getElementById(id).style.display = value;
}

function showOptions(id, value)
{
    if(value == false)
    	value = '';
        
	if(value != '')
        setDisplay(id, 'block');
    else
        setDisplay(id, 'none');
}

function setAttribute(id, attribute, value)
{
    document.getElementById(id).setAttribute(attribute, value);
}

function replaceEnter()
{
    $('.input-field').keypress(function(e) {
    	if (e.which == 13) {
            
        	$(this).closest('tr').next().find('.input-field').first().focus();
        	e.preventDefault();
    	}
	});
}

function toggle(source, class_name) 
{
    var checkboxes = document.getElementsByClassName(class_name);
    
    for(var i = 0, n = checkboxes.length; i < n; i++)
        checkboxes[i].checked = source.checked;
}
         
function adjustTZ(datetime)
    {
        datetime.getTimezoneOffset();
    }