cookie usercookie: {Id: int}

		     
		     
		   
table users: {Id: int, Username: string, Email: string}
table questions: {Id: int, Question: string, Answer: int}
table answers: {Id: int, QuestionId: int, UserId: int, AnswerMin: int, AnswerMax: int, Confidence: float}

(*Answers can be:
    a range of numbers
    (later) a list of strings
    (later) a minimum number
    (later) a maximum number
    (later) a single string*)
	       
(* TODO: write result datatype so that questions can have string
results as well, or float results*)

(* Sequences: for changing ids*)

(* Tasks: for code done on initialization*)
(* task initialize = ((some function from unit to transaction unit)) *)
(* also note clientLeaves -- useful for chat clients *)


task initialize =
 fn () =>
    dml (INSERT INTO questions (Id, Question, Answer)
	 VALUES (1, "Is mayonnaise an instrument?", 0));
    dml (INSERT INTO questions (Id, Question, Answer)
	 VALUES (1, "How old is Barack Obama?", 53));
    dml (INSERT INTO questions (Id, Question, Answer)
	 VALUES (1, "How many milliliters in a liter?", 1000));
    return ()

(* Non-page-returning helper functions *)

fun newAnonUser () : transaction int =
    (* Note: Should return an int for the unique user ID *)
    let val id = 42 in 
	dml (INSERT INTO users (Id, Username, Email)
	     VALUES ({[id]}, "blah", "blah"));
	return 42
    end
		
fun globalPageHook () =
    return ()

(* To-do list:
   - Grading and storing data when user answers question
   - Display shiny homepage stats
   - Display shiny calibration graph
   - More nuanced question types and result types
   - Friends features -- add friend requests, see how friends are doing, see friend requests
   - Gravatar features
   - Points features
   - ...badges? o_O
*)

(* Page-returning functions *)
		    
fun main () =
    globalPageHook ();
    (* Todo: Only pick from those questions the user hasn't answered yet. *)
    questions <- queryX (SELECT * FROM questions)
		 (fn row => <xml><p><a link={question row.Questions.Question}>{[row.Questions.Question]}</a></p></xml>);
    return <xml>
      <head><title>Main</title></head><body>
	<h1>Hello, world!</h1>
	<p><a link={settings ""}>Settings</a></p>
	<p><a link={question "Is mayonnaise an instrument?"}>Is mayonnaise an instrument?</a></p>
	{questions}
    </body></xml>

and settings cookiemsg =
    (* cookiemsg :: Maybe string *)
    globalPageHook ();
    return <xml>
      <head><title>Settings</title></head><body>
	<p>Manage your settings here.</p>
	<i>{[cookiemsg]}</i>
	<form>
	  <submit action={maybeSetCookie} value="Remember me on this computer (with a cookie)"/>
	</form>
	<form>
	  <submit action={maybeDeleteCookie} value="Delete my cookie"/>
	</form>
	<p><a link={main ()}>Return to main menu</a></p>
      </body></xml>

(* Todo: If the user has already answered the question, show here instead a shiny page with their previous answers, and maybe their friends' answers later.*)
and question questionText = 
    globalPageHook ();
    return <xml>
      <head><title>Question: {[questionText]}</title></head><body>
	<p>Current question: {[questionText]}</p>
	<form>
	  <p>Your answer: <textbox{#Answer}/></p>
	  <p>Your confidence: <textbox{#Confidence}/></p>
	  <p><submit action={answerHandler questionText}/></p>
	</form>
	<p><a link={main ()}>Return to main menu</a></p>
    </body></xml>

and answerHandler questionText r =
  globalPageHook ();
  return <xml>
    <head><title>Answer: {[questionText]}</title></head><body>
      <p>Current question: {[questionText]}</p>
      <p>You answered {[r.Answer]} with {[r.Confidence]}% confidence.</p>
      <p><a link={main ()}>Return to main menu</a></p>
  </body></xml>

and maybeSetCookie unused =
    uc <- getCookie usercookie;
    case uc of
	None =>
	uid <- newAnonUser ();
	setCookie usercookie {Value = {Id = uid},
			      Expires = None,
			      Secure = False};
	settings "Cookie set!"
      | Some uid => settings "Cookie was already set."

and maybeDeleteCookie unused =
    clearCookie usercookie;
    settings "Cookie deleted!"
